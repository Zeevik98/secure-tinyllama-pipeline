output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint URL"
  value       = module.eks.cluster_endpoint
}
