#!/bin/bash
# setup_runner.sh
# Run once as root on the Linode server to install the GitHub Actions self-hosted runner.
#
# Before running, get a registration token from:
#   GitHub repo → Settings → Actions → Runners → New self-hosted runner
#
# Usage: bash setup_runner.sh <repo-url> <registration-token>
#   e.g. bash setup_runner.sh https://github.com/evolvingsewage/perez_wiki AABBCC...

set -euo pipefail

REPO_URL="${1:?Usage: $0 <repo-url> <registration-token>}"
REG_TOKEN="${2:?Usage: $0 <repo-url> <registration-token>}"
RUNNER_USER="github-runner"
RUNNER_HOME="/home/${RUNNER_USER}/actions-runner"

# Create dedicated runner user if it doesn't exist
if ! id "$RUNNER_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$RUNNER_USER"
    echo "Created user: ${RUNNER_USER}"
fi

# Allow runner to restart the app service without a password
SUDOERS_FILE="/etc/sudoers.d/github-runner"
echo "${RUNNER_USER} ALL=(ALL) NOPASSWD: /bin/systemctl restart perez_wiki" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

# Download the latest runner
mkdir -p "$RUNNER_HOME"
cd "$RUNNER_HOME"

RUNNER_VERSION=$(curl -sf https://api.github.com/repos/actions/runner/releases/latest | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'].lstrip('v'))")
RUNNER_ARCHIVE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

echo "Downloading GitHub Actions runner v${RUNNER_VERSION}..."
curl -sLO "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_ARCHIVE}"
tar xzf "$RUNNER_ARCHIVE"
rm "$RUNNER_ARCHIVE"

# Set ownership
chown -R "${RUNNER_USER}:${RUNNER_USER}" "$RUNNER_HOME"

# Configure the runner
echo "Configuring runner..."
sudo -u "$RUNNER_USER" ./config.sh \
    --url "$REPO_URL" \
    --token "$REG_TOKEN" \
    --name "linode-perez-wiki" \
    --labels "self-hosted" \
    --work "_work" \
    --unattended

# Install and start as a systemd service
./svc.sh install "$RUNNER_USER"
./svc.sh start

echo ""
echo "Done. Runner status:"
./svc.sh status
