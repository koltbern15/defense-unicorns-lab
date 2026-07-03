#!/usr/bin/env bash
# lab-status.sh — read-only health check across both lab clusters. No mutations.
# Assumes: WSL Ubuntu with brew/nvm on PATH; k3d clusters named "uds" and
# "zarf-tutorial" (kube contexts k3d-uds and k3d-zarf-tutorial).
set -uo pipefail

echo "=== k3d clusters ==="
k3d cluster list 2>&1 </dev/null

echo
echo "=== kube contexts ==="
kubectl config get-contexts 2>&1 </dev/null

echo
echo "=== uds cluster: lab-sso-app pods ==="
kubectl --context k3d-uds get pods -n lab-sso-app -o wide 2>&1 </dev/null

echo
echo "=== uds cluster: podinfo Package CR status ==="
kubectl --context k3d-uds get package podinfo -n lab-sso-app -o jsonpath='{.status.phase}' 2>&1 </dev/null
echo

echo
echo "=== uds cluster: overall pod health (non-Running/non-Completed) ==="
kubectl --context k3d-uds get pods -A --no-headers 2>/dev/null | awk '$4 != "Running" && $4 != "Completed"' </dev/null
echo "(empty = all healthy)"

echo
echo "=== zarf-tutorial cluster: overall pod health ==="
kubectl --context k3d-zarf-tutorial get pods -A --no-headers 2>/dev/null | awk '$4 != "Running" && $4 != "Completed"' </dev/null
echo "(empty = all healthy)"

echo
echo "=== tunnels (8888 keycloak, 8889 registry) ==="
ss -tlnp 2>/dev/null | grep -E ':8888|:8889' </dev/null || echo "no tunnels listening"

echo
echo "=== containerd: podinfo images on uds node ==="
docker exec k3d-uds-server-0 ctr -n k8s.io images ls 2>&1 </dev/null | grep -i podinfo || echo "no podinfo images found"

echo
echo "=== lula2 present ==="
npx --yes lula2 --version 2>/dev/null | head -1 || echo "lula2 runs via npx on demand"
