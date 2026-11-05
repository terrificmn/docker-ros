# Prod: secure remote rosbridge access (wss via nginx)

Public raw `ws://...:9090` lets anyone on the internet drive the robot
(no auth in rosbridge). On prod, rosbridge stays localhost-only and remote
browsers go through an authenticated TLS proxy instead:

```
browser --wss://luhana.ddns.net/rosbridge/?token=SECRET--> nginx:443 (token check)
                                                          --http://ros2:9090--> rosbridge
```

Router port 80 is unusable (gateway admin), so the TLS certificate is issued
via TLS-ALPN-01 on port 443. Renewals restart nginx for a few seconds
(~every 60 days).

## One-time setup (on prod)

Prereqs: router forwards `443 -> 443` to prod; this repo pulled on prod.

1. Install certbot (Ubuntu/Debian):
   ```bash
   sudo snap install --classic certbot
   sudo ln -sf /snap/bin/certbot /usr/bin/certbot
   ```

2. Issue the certificate. Port 443 must be free, so run this BEFORE
   bringing up the prod overlay (base compose has no 443 mapping):
   ```bash
   sudo certbot certonly --standalone --preferred-challenges tls-alpn \
     -d luhana.ddns.net -m you@example.com --agree-tos --no-eff-email \
     --pre-hook "docker stop jazzy-web_nginx" \
     --post-hook "docker start jazzy-web_nginx"
   ```
   (Hooks are saved and re-run at each renewal. If your prod containers
   are not named `jazzy-web_*`, adjust the hook commands; check `docker ps`.)
   Renewals are automatic (snap runs `certbot renew` twice a day).

3. Generate the proxy conf + token:
   ```bash
   ./scripts/setup-rosbridge-ssl.sh
   ```
   Copy the printed `VITE_ROSBRIDGE_URL`.

4. Enable the prod overlay permanently (parent repo `.env` on prod):
   ```bash
   echo 'COMPOSE_FILE=docker-compose.yml:docker-compose-prod.yml' >> .env
   docker compose up -d
   ```

5. Point the frontend at the proxy. In `web_ws/home_monitor/.env` ON PROD:
   ```
   VITE_ROSBRIDGE_URL="wss://luhana.ddns.net/rosbridge/?token=<token from step 3>"
   ```
   Then rebuild (VITE_* is baked in at build time):
   ```bash
   docker exec jazzy-web_php bash -c "cd /var/www/html/home_monitor && npm run build"
   ```
   (Container name as above: adjust if yours differs.)

6. Verify:
   ```bash
   curl -sk -o /dev/null -w "no token: %{http_code} (want 403)\n" \
     https://luhana.ddns.net/rosbridge/
   curl -sk -o /dev/null -w "bad token: %{http_code} (want 403)\n" \
     "https://luhana.ddns.net/rosbridge/?token=wrong"
   curl -sk -o /dev/null -w "good token, plain GET: %{http_code} (want 400 from rosbridge)\n" \
     "https://luhana.ddns.net/rosbridge/?token=<token>"
   ```
   Then open the camera page remotely and confirm it connects.

7. Router: DELETE the `9090` forwarding rule. Keep `443 -> 443`
   (required, also for renewals) and `8000 -> 8000` (the page).

## Ongoing deploys

- Pull BOTH repos on prod (`docker-jazzy-home` and nested `web_ws/home_monitor`).
- `docker compose up -d`, rebuild frontend if it changed.
- `nginx/rosbridge-ssl.conf` is generated + gitignored: never commit it.
  If missing (fresh clone), re-run step 3 (new token -> update prod
  `VITE_ROSBRIDGE_URL` + rebuild).

## Token rotation

Re-run `./scripts/setup-rosbridge-ssl.sh`, `docker compose up -d web`,
update prod `VITE_ROSBRIDGE_URL`, rebuild.

## Security notes

- The token is baked into the public JS bundle, so it stops scanners and
  unauthenticated internet access, but a determined attacker targeting this
  specific host could extract it. The camera page itself still requires a
  Laravel login. A fully session-bound proxy is possible future work.
- `127.0.0.1:9090` binding is kept for local debugging (`wscat`, `curl`
  from the prod host itself).
