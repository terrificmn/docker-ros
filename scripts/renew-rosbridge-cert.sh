#!/usr/bin/env bash
# Renew the lego TLS cert if due; briefly restarts nginx for the TLS-ALPN-01
# challenge on port 443. lego's pre/post hooks fire only when a certificate
# is actually created/renewed, so this is a no-op (no nginx restart) while
# the cert is fresh. Cron (weekly, as root):
#   0 3 * * 0 /path/to/docker-jazzy-home/scripts/renew-rosbridge-cert.sh luhana.ddns.net you@example.com
set -euo pipefail

DOMAIN="${1:?usage: $0 <domain> <email>}"
EMAIL="${2:?usage: $0 <domain> <email>}"
LEGO=/usr/local/bin/lego
NGINX_CONTAINER=jazzy-web_nginx   # adjust if your prod project name differs

exec "$LEGO" run --email="$EMAIL" --domains="$DOMAIN" --tls --path="/srv/lego" \
  --accept-tos --renew-days 30 \
  --pre-hook "docker stop $NGINX_CONTAINER" \
  --post-hook "docker start $NGINX_CONTAINER"
