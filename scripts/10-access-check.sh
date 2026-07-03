#!/usr/bin/env bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo '=== connect shortcuts ==='
uds zarf connect list 2>&1 | tail -12
echo '=== k3d port mappings ==='
docker ps --filter name=k3d-uds-serverlb --format '{{.Ports}}'
echo '=== gateway URLs from inside WSL ==='
for u in https://keycloak.admin.uds.dev https://grafana.admin.uds.dev https://sso.uds.dev; do
  code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "$u")
  echo "$u -> HTTP $code"
done
echo '=== grafana admin secret keys ==='
kubectl get secret -n grafana grafana -o jsonpath='{.data}' | tr ',' '\n' | cut -d'"' -f2 | tr '\n' ' '
echo ''
echo '=== keycloak admin hints ==='
kubectl get sts -n keycloak keycloak -o yaml 2>/dev/null | grep -iE 'ADMIN|BOOTSTRAP' | head -10
echo ACCESS_DONE
