#!/usr/bin/env bash
# bind-service-to-waypoint.sh — apply the waypoint fix labels (istio.io/use-waypoint +
# istio.io/ingress-use-waypoint) to the podinfo Service, then verify the SSO redirect.
# Mirrors the working keycloak Service's label pattern (War Story 2 fix).
# Assumes: WSL Ubuntu, brew/nvm on PATH, k3d clusters "uds" + "zarf-tutorial".
set -uo pipefail
CTX="--context k3d-uds"
NS="lab-sso-app"

echo "=== label the service ==="
kubectl $CTX label svc podinfo -n $NS \
  istio.io/use-waypoint=uds-lab-podinfo-waypoint \
  istio.io/ingress-use-waypoint=true --overwrite </dev/null

echo
echo "=== curl poll (expect 302 -> sso.uds.dev) ==="
for i in $(seq 1 18); do
  OUT=$(curl -sk -o /dev/null -w '%{http_code} %{redirect_url}' --max-time 15 https://podinfo.uds.dev/ </dev/null)
  echo "  [$((i*5))s] $OUT"
  case "$OUT" in 30*sso.uds.dev*) echo; echo "SUCCESS: SSO redirect verified — the Conditional Access moment"; exit 0;; esac
  sleep 5
done
echo "no redirect yet — waypoint log tail:"
WPPOD=$(kubectl $CTX get pods -n $NS -o name </dev/null | grep waypoint | head -1)
kubectl $CTX logs -n $NS "$WPPOD" --since=2m </dev/null 2>/dev/null | tail -6
exit 1
