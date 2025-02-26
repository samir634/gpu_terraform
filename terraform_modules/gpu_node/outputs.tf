output "instance_ids" {
  description = "The IDs of the GPU instances"
  value       = aws_instance.gpu_instance[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses of the GPU instances"
  value       = aws_instance.gpu_instance[*].public_ip
}
