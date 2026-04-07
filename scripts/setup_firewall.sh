#!/bin/bash
# setup_firewall.sh
# Run once as root on the Linode server to configure UFW.
# Opens HTTP/HTTPS to all, SSH only to GitHub Actions runner IPs.

set -euo pipefail

GH_IPS_FILE="/etc/ufw/github_actions_ips.txt"

command -v ufw >/dev/null 2>&1 || apt-get install -y ufw
command -v curl >/dev/null 2>&1 || apt-get install -y curl
command -v python3 >/dev/null 2>&1 || apt-get install -y python3

ufw --force reset

ufw default deny incoming
ufw default allow outgoing

# Web traffic
ufw allow 80/tcp
ufw allow 443/tcp

# Fetch GitHub Actions runner IPs and allow SSH from each
echo "Fetching GitHub Actions IP ranges..."
GH_IPS=$(curl -sf https://api.github.com/meta | python3 -c "
import sys, json
meta = json.load(sys.stdin)
for ip in meta['actions']:
    print(ip)
")

echo "$GH_IPS" > "$GH_IPS_FILE"

while IFS= read -r ip; do
    ufw allow from "$ip" to any port 22 proto tcp
done <<< "$GH_IPS"

ufw --force enable
ufw status verbose

echo ""
echo "Done. Allowed $(wc -l < "$GH_IPS_FILE") GitHub Actions CIDR ranges on port 22."
echo "Run scripts/update_gh_ips.sh weekly (or via cron) to keep IPs current."
