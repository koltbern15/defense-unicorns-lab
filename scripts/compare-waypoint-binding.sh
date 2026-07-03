#!/usr/bin/env bash
# compare-waypoint-binding.sh — read-only diff of Istio waypoint binding labels between the
# working keycloak namespace and lab-sso-app. This diff-against-working-keycloak technique
# found the waypoint Service-labeling root cause (operator labeled the pod, not the Service).
# Assumes: WSL Ubuntu, brew/nvm on PATH, k3d clusters "uds" + "zarf-tutorial" (context k3d-uds).
set -uo pipefail
CTX="--context k3d-uds"

echo "=== WORKING REFERENCE: keycloak ==="
echo "-- ns labels:"
kubectl $CTX get ns keycloak -o jsonpath='{.metadata.labels}' </dev/null; echo
echo "-- keycloak services + labels:"
kubectl $CTX get svc -n keycloak -o jsonpath='{range .items[*]}{.metadata.name}: {.metadata.labels}{"\n"}{end}' </dev/null
echo "-- keycloak pod labels (waypoint-related):"
kubectl $CTX get pods -n keycloak -o jsonpath='{range .items[*]}{.metadata.name}: {.metadata.labels.istio\.io/use-waypoint}{"\n"}{end}' </dev/null

echo
echo "=== OURS: lab-sso-app ==="
echo "-- ns labels:"
kubectl $CTX get ns lab-sso-app -o jsonpath='{.metadata.labels}' </dev/null; echo
echo "-- services + labels:"
kubectl $CTX get svc -n lab-sso-app -o jsonpath='{range .items[*]}{.metadata.name}: {.metadata.labels}{"\n"}{end}' </dev/null
echo "-- podinfo pod full labels:"
kubectl $CTX get pods -n lab-sso-app -l app=podinfo -o jsonpath='{.items[0].metadata.labels}' </dev/null; echo

echo
echo "=== also: grafana (another authservice-protected app) for comparison ==="
kubectl $CTX get svc -n grafana -o jsonpath='{range .items[*]}{.metadata.name}: {.metadata.labels}{"\n"}{end}' </dev/null 2>/dev/null | head -4
