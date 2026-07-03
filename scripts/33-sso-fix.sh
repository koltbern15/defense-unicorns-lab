#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null

echo '=== 1. put namespace back under zarf agent management ==='
kubectl label ns lab-sso-app zarf.dev/agent- 2>/dev/null || true
kubectl delete pods --all -n lab-sso-app --wait=false

echo '=== 2. wait for recreated podinfo pod, read rewritten image ref ==='
sleep 10
REF=""
for i in $(seq 1 12); do
  REF=$(kubectl get pods -n lab-sso-app -l app=podinfo -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null || true)
  [ -n "$REF" ] && break
  sleep 5
done
echo "rewritten ref: $REF"
case "$REF" in
  127.0.0.1:31999/*) ;;
  *) echo "UNEXPECTED REF - aborting"; exit 1 ;;
esac

echo '=== 3. copy public image into the internal zarf registry ==='
zarf tools registry copy "ghcr.io/stefanprodan/podinfo:6.7.1" "$REF" 2>&1 | tail -3

echo '=== 4. force pull retry ==='
kubectl delete pods -n lab-sso-app -l app=podinfo --wait=false
sleep 5
kubectl rollout status deploy/podinfo -n lab-sso-app --timeout=180s | tail -1

echo '=== 5. wait for waypoint + package Ready ==='
phase=""
for i in $(seq 1 36); do
  phase=$(kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status.phase}' 2>/dev/null)
  [ "$phase" = "Ready" ] && break
  sleep 5
done
echo "package phase: $phase"
kubectl get pods -n lab-sso-app --no-headers

echo '=== 6. the Conditional Access moment ==='
code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 15 https://podinfo.uds.dev/)
loc=$(curl -sk -o /dev/null -w '%{redirect_url}' --max-time 15 https://podinfo.uds.dev/)
echo "GET https://podinfo.uds.dev -> HTTP $code"
echo "redirects to: $loc"
echo SSO_FIX_DONE
