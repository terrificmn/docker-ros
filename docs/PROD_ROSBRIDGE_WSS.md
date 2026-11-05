# Prod: secure remote rosbridge access (wss via nginx)

Public raw `ws://...:9090` lets anyone on the internet drive the robot
(no auth in rosbridge). On prod, rosbridge stays localhost-only and remote
browsers go through an authenticated TLS proxy instead:

```
browser --wss://luhana.ddns.net/rosbridge/?token=SECRET--> nginx:443 (token check)
                                                          --http://ros2:9090--> rosbridge
```

Router port 80 is unusable (gateway admin), so the TLS certificate is issued
with the TLS-ALPN-01 challenge on port 443 via `lego` (a static Go binary;
note: certbot's standalone mode does NOT support that challenge). Renewals
briefly restart nginx (~every 60 days; a weekly cron check restarts only
when a renewal is actually due).

## One-time setup (on prod)

Prereqs: router forwards `443 -> 443` to prod; this repo pulled on prod.

1. Install lego v5.6.0 (static binary, incl. aarch64; `-f` makes curl
   fail loudly instead of saving an error page):
   ```bash
   curl -fSL "https://github.com/go-acme/lego/releases/download/v5.6.0/lego_v5.6.0_linux_arm64.tar.gz" -o /tmp/lego.tgz
   tar -tzf /tmp/lego.tgz
   tar -xzf /tmp/lego.tgz -C /tmp lego && sudo install -m 0755 /tmp/lego /usr/local/bin/lego
   lego --version
   ```
*lego version 5.6.0 linux/arm64*  

2. Issue the certificate. Port 443 must be free, so run this BEFORE
   bringing up the prod overlay (base compose has no 443 mapping):
   ```bash
   sudo /usr/local/bin/lego run --email="you@example.com" --domains="luhana.ddns.net" \
     --tls --path="/srv/lego" --accept-tos
   ```
   Use your real email (expiry warnings). Files land in
   `/srv/lego/certificates/`.

   참고로 sudo  ls /srv/lego/certificates 해보면 key, crt 파일들이 있어야 한다.  

3. Generate the proxy conf + token:
   ```bash
   ./scripts/setup-rosbridge-ssl.sh
   ```
   Copy the printed `VITE_ROSBRIDGE_URL`.  
   여기에서 나온 token 을 사용해야 한다. 이후 npm 빌드까지 해준다.  

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
   (If your prod containers are not named `jazzy-web_*`, check `docker ps`
   and adjust.)

6. Verify:
   ```bash
   curl -sk -o /dev/null -w "no token: %{http_code} (want 403)\n" \
     https://luhana.ddns.net/rosbridge/
   curl -sk -o /dev/null -w "bad token: %{http_code} (want 403)\n" \
     "https://luhana.ddns.net/rosbridge/?token=wrong"
   curl -sk -o /dev/null -w "good token, plain GET: %{http_code} (want 400 from rosbridge)\n" \
     "https://luhana.ddns.net/rosbridge/?token=<token>"
   ```
   여기에서는 403, 403, 400 이 나와야 한다.  
   Then open the camera page remotely and confirm it connects.

7. Router: DELETE the `9090` forwarding rule. Keep `443 -> 443`
   (required, also for renewals) and `8000 -> 8000` (the page).

8. Renewal cron (weekly check, restarts nginx only when the cert is
   within 30 days of expiry):
   ```bash
   sudo crontab -e
   # add (adjust path to this repo):
   0 3 * * 0 /home/YOU/docker-jazzy-home/scripts/renew-rosbridge-cert.sh luhana.ddns.net you@example.com
   ```
   Test it once (should report no renewal is due and NOT restart nginx):
   ```bash
   sudo scripts/renew-rosbridge-cert.sh luhana.ddns.net you@example.com
   ```

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

## Troubleshooting

- `nginx: [emerg] cannot load certificate ... No such file`:
  the certificate was never issued (or was issued for another name).
  Restore the page with the base compose file, issue the cert, then
  re-enable the overlay:
  ```bash
  docker compose -f docker-compose.yml up -d web   # page back, no 443 yet
  sudo ls /srv/lego/certificates/                  # must show luhana.ddns.net.crt
  # ... re-run step 2, then:
  docker compose up -d                              # overlay back on
  ```
- `sudo: unable to resolve host ...`: harmless (missing /etc/hosts entry).
  Optional fix: `echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts`.
