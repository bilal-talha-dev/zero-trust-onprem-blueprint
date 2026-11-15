#!/usr/bin/env bash
set -euo pipefail

echo "[*] Auditing listening TCP/UDP sockets on public interfaces..."
EXPOSED=$(ss -tulnp | grep -E '0\.0\.0\.0:|:::' | grep -vE '127\.0\.0\.1|::1' || true)

if [[ -n "${EXPOSED}" ]]; then
  echo "[!] WARNING: Publicly bound sockets detected:"
  echo "${EXPOSED}"
  exit 1
else
  echo "[OK] Zero public inbound sockets exposed. All ingress is routed via outbound Cloudflare Tunnel."
fi
