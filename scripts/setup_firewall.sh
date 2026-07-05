#!/bin/bash
# setup_firewall.sh
# Run once as root on the Linode server to configure nftables.

set -euo pipefail

NFT_CONF="/etc/nftables/perez_wiki.nft"

command -v curl >/dev/null 2>&1 || apt-get install -y curl

mkdir -p /etc/nftables

cat > "$NFT_CONF" << 'EOF'
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related connections
        ct state established,related accept

        # Allow loopback
        iif lo accept

        # Allow HTTP and HTTPS and SSH
        tcp dport { 22, 80, 443 } accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

# Load the ruleset
nft -f "$NFT_CONF"

# Persist across reboots
if ! grep -q "perez_wiki.nft" /etc/nftables.conf 2>/dev/null; then
    echo "include \"/etc/nftables/perez_wiki.nft\"" >> /etc/nftables.conf
fi
systemctl enable nftables
systemctl restart nftables

echo ""
nft list ruleset
echo ""
echo "Done. SSH is closed, use LISH for access."
