variable "cloudflare_api_token" {
  description = "Cloudflare API token with Tunnel, DNS, and Zero Trust Access permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare DNS Zone ID for the target domain"
  type        = string
}

variable "domain" {
  description = "Root domain managed in Cloudflare (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain routed through the Zero-Trust tunnel"
  type        = string
  default     = "app"
}

variable "tunnel_name" {
  description = "Identifier for the Cloudflare Tunnel"
  type        = string
  default     = "onprem-zero-trust-tunnel"
}

variable "enable_access_policy" {
  description = "Whether to enforce a Cloudflare Zero Trust Access policy in front of the application"
  type        = bool
  default     = true
}

variable "allowed_emails" {
  description = "List of authorized user emails permitted by the Zero Trust Access policy"
  type        = list(string)
  default     = []
}
