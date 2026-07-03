#!/usr/bin/env bash
# verify-sso-redirect.sh — poll https://podinfo.uds.dev until the waypoint settles and
# the request returns a 302 redirect to sso.uds.dev, proving the SSO flow is wired up.
# Assumes: WSL Ubuntu with brew/nvm on PATH; k3d clusters "uds" and "zarf-tutorial".
# Exits 0 on verified redirect; exits 1 (and dumps lab-sso-app pods) after ~90s.
set -uo pipefail
for i in $(seq 1 18); do
  OUT=$(curl -sk -o /dev/null -w '%{http_code} %{redirect_url}' --max-time 15 https://podinfo.uds.dev/ </dev/null)
  echo "  [$((i*5))s] $OUT"
  case "$OUT" in 30*sso.uds.dev*) echo "SUCCESS: SSO redirect verified"; exit 0;; esac
  sleep 5
done
echo "still not redirecting — waypoint pods:"
kubectl --context k3d-uds get pods -n lab-sso-app </dev/null
exit 1
