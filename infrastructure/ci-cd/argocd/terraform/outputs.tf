output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_service_account" {
  description = "Name of the ArgoCD service account"
  value       = kubernetes_service_account.argocd.metadata[0].name
}

output "argocd_role_arn" {
  description = "ARN of the IAM role used by ArgoCD"
  value       = aws_iam_role.argocd.arn
}

output "security_project_name" {
  description = "Name of the ArgoCD security project"
  value       = kubernetes_manifest.security_project.manifest.metadata.name
}

output "security_scanners_app_name" {
  description = "Name of the security scanners ArgoCD application"
  value       = kubernetes_manifest.security_scanners.manifest.metadata.name
}