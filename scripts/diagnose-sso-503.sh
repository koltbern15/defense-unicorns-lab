#!/usr/bin/env bash
# diagnose-sso-503.sh — trace an SSO 503 hop by hop: tenant gateway -> waypoint -> authservice -> ztunnel.
# Read-only: curls podinfo.uds.dev, then pulls service/endpoint state and recent logs at each hop.
# Assumes: WSL Ubuntu with brew/nvm on PATH; k3d clusters "uds" and "zarf-tutorial" (uses context k3d-uds).
set -uo pipefail
CTX="--context k3d-uds"
NS="lab-sso-app"

echo "=== [1] full curl response (headers + body) ==="
curl -sk -D- --max-time 15 https://podinfo.uds.dev/ </dev/null | head -20

echo
echo "=== [2] podinfo service + endpoints ==="
kubectl $CTX get svc podinfo -n $NS -o wide </dev/null
kubectl $CTX get endpointslices -n $NS -l kubernetes.io/service-name=podinfo -o jsonpath='{range .items[*]}{range .endpoints[*]}{.addresses}{" ready="}{.conditions.ready}{"\n"}{end}{end}' </dev/null

echo
echo "=== [3] tenant gateway access log — podinfo lines (response flags!) ==="
GWPOD=$(kubectl $CTX get pods -n istio-tenant-gateway -o name </dev/null | head -1)
kubectl $CTX logs -n istio-tenant-gateway "$GWPOD" --since=10m </dev/null 2>/dev/null | grep -i podinfo | tail -5

echo
echo "=== [4] waypoint access log — last lines ==="
WPPOD=$(kubectl $CTX get pods -n $NS -o name </dev/null | grep waypoint | head -1)
kubectl $CTX logs -n $NS "$WPPOD" --since=10m </dev/null 2>/dev/null | tail -8

echo
echo "=== [5] authservice pods + recent errors ==="
kubectl $CTX get pods -n authservice --no-headers </dev/null 2>&1
ASPOD=$(kubectl $CTX get pods -n authservice -o name </dev/null 2>/dev/null | head -1)
[ -n "${ASPOD:-}" ] && kubectl $CTX logs -n authservice "$ASPOD" --since=10m </dev/null 2>/dev/null | grep -iE 'error|warn|podinfo' | tail -8

echo
echo "=== [6] ztunnel recent podinfo/waypoint lines ==="
ZTPOD=$(kubectl $CTX get pods -n istio-system -o name </dev/null | grep ztunnel | head -1)
kubectl $CTX logs -n istio-system "$ZTPOD" --since=10m </dev/null 2>/dev/null | grep -iE 'podinfo|waypoint|error' | tail -8
