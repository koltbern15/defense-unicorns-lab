#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null

echo '=== import image into k3d node containerd under the rewritten ref ==='
docker tag ghcr.io/stefanprodan/podinfo:6.7.1 127.0.0.1:31999/stefanprodan/podinfo:6.7.1-zarf-2985051089
k3d image import 127.0.0.1:31999/stefanprodan/podinfo:6.7.1-zarf-2985051089 -c uds 2>&1 | tail -2

echo '=== recreate podinfo pod ==='
kubectl delete pods -n lab-sso-app -l app=podinfo --wait=false
kubectl rollout status deploy/podinfo -n lab-sso-app --timeout=180s | tail -1
kubectl get pods -n lab-sso-app --no-headers

echo '=== nudge package reconcile and wait for Ready ==='
kubectl label package podinfo -n lab-sso-app lab-retrigger=1 --overwrite >/dev/null
phase=""
for i in $(seq 1 36); do
  phase=$(kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status.phase}' 2>/dev/null)
  [ "$phase" = "Ready" ] && break
  sleep 5
done
echo "package phase: $phase"

echo '=== the Conditional Access moment ==='
code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 15 https://podinfo.uds.dev/)
loc=$(curl -sk -o /dev/null -w '%{redirect_url}' --max-time 15 https://podinfo.uds.dev/)
echo "GET https://podinfo.uds.dev -> HTTP $code"
echo "redirects to: $loc"
echo IMAGE_IMPORT_DONE
