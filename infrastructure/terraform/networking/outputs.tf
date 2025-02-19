/*
  outputs.tf: Exposes the VPC and subnet IDs for consumption by other modules
*/
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "private_subnets" {
  description = "Private Subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "eks_nodes_sg_id" {
  description = "Security group for EKS nodes"
  value       = aws_security_group.eks_nodes_sg.id
}
