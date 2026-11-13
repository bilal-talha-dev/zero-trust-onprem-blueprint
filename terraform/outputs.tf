output "tunnel_id" {
  description = "Provisioned Cloudflare Tunnel UUID"
  value       = cloudflare_zero_trust_tunnel_cloudflared.onprem_tunnel.id
}

output "tunnel_cname" {
  description = "Cloudflare Tunnel CNAME target"
  value       = "${cloudflare_zero_trust_tunnel_cloudflared.onprem_tunnel.id}.cfargotunnel.com"
}

output "public_hostname" {
  description = "Publicly accessible Zero-Trust hostname"
  value       = "https://${var.subdomain}.${var.domain}"
}

output "tunnel_token" {
  description = "Base64-encoded tunnel token for cloudflared deployment"
  value       = cloudflare_zero_trust_tunnel_cloudflared.onprem_tunnel.tunnel_token
  sensitive   = true
}
