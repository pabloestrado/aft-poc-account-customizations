### Route53
data "aws_route53_zone" "selected" {
  count = var.vpn_create_ssl ? 1 : 0
  name  = var.project_domain
}

# Create Route53 CNAME record for the VPN
resource "aws_route53_record" "openvpn" {
  count   = var.vpn_create_ssl ? 1 : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "vpn.${var.project_domain}"
  type    = "A"
  ttl     = "60"
  records = [aws_eip.openvpn.public_ip]
}
