#!/usr/bin/env bash
# keycloak-tunnel.sh — restart the Keycloak bootstrap tunnel on 8888 (detached) and verify it answers.
# Assumes: WSL Ubuntu with brew/nvm on PATH, k3d clusters "uds" + "zarf-tutorial",
# zarf and kubectl installed. Tunnels do not survive Docker Desktop restarts — rerun after reboot.
set -uo pipefail
command -v zarf >/dev/null || eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "=== pin kubectl context to k3d-uds ==="
kubectl config use-context k3d-uds

echo
echo "=== start tunnel detached ==="
pkill -f 'zarf connect keycloak' 2>/dev/null && sleep 2
nohup setsid zarf connect keycloak --local-port 8888 </dev/null >/tmp/keycloak-tunnel.log 2>&1 &
for i in $(seq 1 15); do
  sleep 2
  CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1:8888/ </dev/null || true)
  if [ "$CODE" != "000" ] && [ -n "$CODE" ]; then break; fi
done
echo "http://127.0.0.1:8888/ -> HTTP $CODE (from Ubuntu)"
[ "$CODE" != "000" ] || { echo "FATAL: tunnel not answering"; cat /tmp/keycloak-tunnel.log; exit 1; }

echo
echo "=== both tunnels now listening ==="
ss -tlnp 2>/dev/null | grep -E ':8888|:8889' </dev/null
