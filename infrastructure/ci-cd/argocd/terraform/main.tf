provider "aws" {
 region = var.aws_region
 default_tags {
   tags = var.tags
 }
}

provider "helm" {
 kubernetes {
   host                   = var.eks_endpoint
   cluster_ca_certificate = base64decode(var.eks_ca_certificate)
   exec {
     api_version = "client.authentication.k8s.io/v1beta1"
     command     = "aws"
     args = [
       "eks",
       "get-token",
       "--cluster-name",
       var.eks_cluster_name
     ]
   }
 }
}

provider "kubernetes" {
 host                   = var.eks_endpoint
 cluster_ca_certificate = base64decode(var.eks_ca_certificate)
 exec {
   api_version = "client.authentication.k8s.io/v1beta1"
   command     = "aws"
   args = [
     "eks",
     "get-token",
     "--cluster-name",
     var.eks_cluster_name
   ]
 }
}

# ArgoCD Namespace with Network Policy
resource "kubernetes_namespace" "argocd" {
 metadata {
   name = var.argocd_namespace
   labels = {
     "app.kubernetes.io/managed-by" = "terraform"
     "istio-injection"              = "enabled"
   }
 }
}

resource "kubernetes_network_policy" "argocd" {
 metadata {
   name      = "argocd-network-policy"
   namespace = kubernetes_namespace.argocd.metadata[0].name
 }

 spec {
   pod_selector {}
   
   ingress {
     from {
       namespace_selector {
         match_labels = {
           "kubernetes.io/metadata.name" = "security-testing"
         }
       }
     }
   }

   egress {
     to {
       namespace_selector {
         match_labels = {
           "kubernetes.io/metadata.name" = "security-testing"
         }
       }
     }
   }

   policy_types = ["Ingress", "Egress"]
 }
}

# ArgoCD Installation
resource "helm_release" "argocd" {
 name       = "argocd"
 repository = "https://argoproj.github.io/argo-helm"
 chart      = "argo-cd"
 version    = var.argocd_helm_version
 namespace  = kubernetes_namespace.argocd.metadata[0].name

 values = [
   <<-EOT
   server:
     replicas: ${var.high_availability ? 3 : 1}
     serviceAccount:
       name: ${local.service_account_name}
       annotations:
         eks.amazonaws.com/role-arn: ${aws_iam_role.argocd.arn}
     
     config:
       resource.customizations: |
         argoproj.io/Application:
           health.lua: |
             hs = {}
             hs.status = "Progressing"
             hs.message = ""
             if obj.status ~= nil then
               if obj.status.health ~= nil then
                 hs.status = obj.status.health.status
                 if obj.status.health.message ~= nil then
                   hs.message = obj.status.health.message
                 end
               end
             end
             return hs

     service:
       type: ClusterIP

   redis:
     enabled: true
     replicas: ${var.high_availability ? 3 : 1}

   repoServer:
     replicas: ${var.high_availability ? 3 : 1}

   applicationSet:
     enabled: true
     replicas: ${var.high_availability ? 3 : 1}

   notifications:
     enabled: true

   monitoring:
     enabled: true
     serviceMonitor:
       enabled: true
   EOT
 ]

 depends_on = [
   kubernetes_namespace.argocd,
   kubernetes_network_policy.argocd,
   aws_iam_role.argocd
 ]
}

# ArgoCD Project
resource "kubernetes_manifest" "security_project" {
 manifest = {
   apiVersion = "argoproj.io/v1alpha1"
   kind       = "AppProject"
   metadata = {
     name      = "security"
     namespace = kubernetes_namespace.argocd.metadata[0].name
   }
   spec = {
     description = "Security tools and scanners"
     sourceRepos = [
       "https://github.com/${var.github_organization}/${var.github_repository}"
     ]
     destinations = [
       {
         namespace = "security-testing"
         server    = "https://kubernetes.default.svc"
       }
     ]
     clusterResourceWhitelist = [
       {
         group = "*"
         kind  = "*"
       }
     ]
   }
 }
 depends_on = [helm_release.argocd]
}

# Security Scanners Application
resource "kubernetes_manifest" "security_scanners" {
 manifest = {
   apiVersion = "argoproj.io/v1alpha1"
   kind       = "Application"
   metadata = {
     name      = "security-scanners"
     namespace = kubernetes_namespace.argocd.metadata[0].name
   }
   spec = {
     project = kubernetes_manifest.security_project.manifest.metadata.name
     source = {
       repoURL        = "https://github.com/${var.github_organization}/${var.github_repository}"
       targetRevision = "HEAD"
       path           = "infrastructure/kubernetes/security-namespace"
     }
     destination = {
       server    = "https://kubernetes.default.svc"
       namespace = "security-testing"
     }
     syncPolicy = {
       automated = {
         prune     = true
         selfHeal  = true
       }
       syncOptions = ["CreateNamespace=true"]
     }
   }
 }
 depends_on = [kubernetes_manifest.security_project]
}

# Service Account
resource "kubernetes_service_account" "argocd" {
 metadata {
   name      = local.service_account_name
   namespace = kubernetes_namespace.argocd.metadata[0].name
   annotations = {
     "eks.amazonaws.com/role-arn" = aws_iam_role.argocd.arn
   }
 }
}

locals {
 service_account_name = "argocd-server"
}