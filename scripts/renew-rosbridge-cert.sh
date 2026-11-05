#!/usr/bin/env bash
# Renew the lego TLS cert when expiring soon; briefly restarts nginx for the
# TLS-ALPN-01 challenge on port 443. Safe to run often: exits quietly if the
# cert is still fresh. Cron (weekly, as root):
#   0 3 * * 0 /path/to/docker-jazzy-home/scripts/renew-rosbridge-cert.sh luhana.ddns.net you@example.com
set -euo pipefail

DOMAIN="${1:?usage: $0 <domain> <email>}"
EMAIL="${2:?usage: $0 <domain> <email>}"
LEGO=/usr/local/bin/lego
LEGO_PATH=/srv/lego
CRT="$LEGO_PATH/certificates/$DOMAIN.crt"
NGINX_CONTAINER=jazzy-web_nginx   # adjust if your prod project name differs

[ -f "$CRT" ] || { echo "missing $CRT: run initial issuance first (runbook step 2)"; exit 1; }
if openssl x509 -checkend $((30*86400)) -noout -in "$CRT"; then
  echo "cert fresh, nothing to do"
  exit 0
fi

echo "cert expiring soon, renewing (nginx restarts briefly)..."
docker stop "$NGINX_CONTAINER" >/dev/null
trap 'docker start "$NGINX_CONTAINER" >/dev/null' EXIT
"$LEGO" --email="$EMAIL" --domains="$DOMAIN" --tls --path="$LEGO_PATH" renew --days 30
docker start "$NGINX_CONTAINER" >/dev/null
trap - EXIT
echo "renewed OK"
