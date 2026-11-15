#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "[!] Please run as root (e.g., sudo bash scripts/bootstrap-node.sh)"
  exit 1
fi

ALLOW_LAN_SSH="${ALLOW_LAN_SSH:-false}"

echo "[1/4] Updating system packages and installing security tooling..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  ufw \
  fail2ban \
  unattended-upgrades

echo "[2/4] Applying kernel network hardening..."
cat <<'EOF' > /etc/sysctl.d/99-zero-trust.conf
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.tcp_syncookies = 1
EOF
sysctl --system >/dev/null

echo "[3/4] Configuring default-deny UFW firewall (0 public inbound ports)..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

if [[ "${ALLOW_LAN_SSH}" == "true" ]]; then
  echo "[*] Permitting SSH exclusively from RFC1918 private LAN subnets..."
  ufw allow from 10.0.0.0/8 to any port 22 proto tcp
  ufw allow from 172.16.0.0/12 to any port 22 proto tcp
  ufw allow from 192.168.0.0/16 to any port 22 proto tcp
fi

ufw --force enable
systemctl enable --now fail2ban

echo "[4/4] Installing lightweight K3s without Traefik or ServiceLB..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=servicelb --write-kubeconfig-mode=644" sh -

echo "[*] Waiting for K3s node to become Ready..."
kubectl wait --for=condition=Ready node --all --timeout=120s

echo "[OK] Node hardened and K3s bootstrapped. Run 'bash scripts/verify-zero-ports.sh' to audit sockets."
