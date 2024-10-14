### Outputs
output "ami" {
  description = "OpenVPN server AMI ID"
  value       = data.aws_ami.openvpn.image_id
}
output "id" {
  description = "OpenVPN instance ID"
  value       = aws_instance.openvpn.id
}
output "sg" {
  description = "OpenVPN Security Group ID"
  value       = aws_security_group.openvpn.id
}
output "public_ip" {
  description = "OpenVPN server public IP"
  value       = aws_eip.openvpn.public_ip
}
output "private_ip" {
  description = "OpenVPN server private IP"
  value       = aws_instance.openvpn.private_ip
}
output "admin_user" {
  description = "OpenVPN Admin user name"
  value       = var.admin_user
  sensitive   = true
}
output "admin_pass" {
  description = "OpenVPN Admin user password"
  value       = random_password.openvpn-admin.result
  sensitive   = true
}
