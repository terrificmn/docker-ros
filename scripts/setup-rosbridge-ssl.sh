#!/usr/bin/env bash
# Generates the prod-only nginx TLS proxy conf for rosbridge (secret token + template).
# Run ON prod (and re-run to rotate the token; then rebuild the frontend):
#   ./scripts/setup-rosbridge-ssl.sh
set -euo pipefail
cd "$(dirname "$0")/.."

TEMPLATE=nginx/rosbridge-ssl.conf.example
OUT=nginx/rosbridge-ssl.conf

TOKEN=$(openssl rand -hex 24)
sed "s/TOKEN_PLACEHOLDER/${TOKEN}/" "$TEMPLATE" > "$OUT"
chmod 600 "$OUT"

echo "Wrote $OUT (gitignored, do not commit)."
echo
echo "Next: set this in home_monitor/.env ON PROD, then rebuild the frontend:"
echo "  VITE_ROSBRIDGE_URL=\"wss://luhana.ddns.net/rosbridge/?token=${TOKEN}\""
