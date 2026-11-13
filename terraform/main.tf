terraform {
  required_version = ">= 1.6.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "random_id" "tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "onprem_tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_record" "app_dns" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.onprem_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
  comment = "Managed by Terraform: Zero-Trust On-Premise Tunnel"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.onprem_tunnel.id

  config {
    ingress_rule {
      hostname = "${var.subdomain}.${var.domain}"
      service  = "http://app-service.onprem-apps.svc.cluster.local:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_zero_trust_access_application" "app_access" {
  count = var.enable_access_policy ? 1 : 0

  account_id                = var.cloudflare_account_id
  name                      = "${var.tunnel_name}-access"
  domain                    = "${var.subdomain}.${var.domain}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_zero_trust_access_policy" "allow_authorized_users" {
  count = var.enable_access_policy && length(var.allowed_emails) > 0 ? 1 : 0

  application_id = cloudflare_zero_trust_access_application.app_access[0].id
  account_id     = var.cloudflare_account_id
  name           = "allow-authorized-emails"
  precedence     = 1
  decision       = "allow"

  include {
    email = var.allowed_emails
  }
}
