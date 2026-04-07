#!/bin/bash
# update_gh_ips.sh
# Refreshes UFW SSH rules to match current GitHub Actions runner IP ranges.
# GitHub updates these ranges ~weekly. Run this on a cron, e.g.:
#   0 3 * * 0   root   /home/user/perez_wiki/scripts/update_gh_ips.sh >> /var/log/update_gh_ips.log 2>&1

set -euo pipefail

GH_IPS_FILE="/etc/ufw/github_actions_ips.txt"

if [[ $EUID -ne 0 ]]; then
    echo "Error: must run as root." >&2
    exit 1
fi

# Remove previously added GitHub Actions SSH rules
if [[ -f "$GH_IPS_FILE" ]]; then
    echo "Removing old GitHub Actions SSH rules..."
    while IFS= read -r old_ip; do
        ufw delete allow from "$old_ip" to any port 22 proto tcp 2>/dev/null || true
    done < "$GH_IPS_FILE"
fi

# Fetch current IP ranges
echo "Fetching GitHub Actions IP ranges..."
NEW_IPS=$(curl -sf https://api.github.com/meta | python3 -c "
import sys, json
meta = json.load(sys.stdin)
for ip in meta['actions']:
    print(ip)
")

echo "$NEW_IPS" > "$GH_IPS_FILE"

# Add updated rules
while IFS= read -r ip; do
    ufw allow from "$ip" to any port 22 proto tcp
done <<< "$NEW_IPS"

ufw reload

echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') — Updated $(wc -l < "$GH_IPS_FILE") GitHub Actions CIDR ranges."
