#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null

echo '=== why is the waypoint still failing? ==='
kubectl get pod -n lab-sso-app -l 'gateway.networking.k8s.io/gateway-name' -o jsonpath='{.items[0].spec.imagePullSecrets}' 2>/dev/null; echo ''
kubectl describe pod -n lab-sso-app -l 'gateway.networking.k8s.io/gateway-name' 2>/dev/null | tail -4
echo '--- ns secrets ---'
kubectl get secrets -n lab-sso-app --no-headers

echo '=== open registry tunnel ==='
pkill -f 'zarf connect registry' 2>/dev/null || true
nohup zarf connect registry --local-port 8889 > /tmp/registry-tunnel.log 2>&1 &
sleep 8
tail -1 /tmp/registry-tunnel.log

echo '=== login and copy image ==='
PUSH_PASS=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | grep -o '"pushPassword":"[^"]*"' | cut -d'"' -f4)
echo "push password retrieved: ${#PUSH_PASS} chars"
zarf tools registry login 127.0.0.1:8889 -u zarf-push -p "$PUSH_PASS" 2>&1 | tail -1
zarf tools registry copy "ghcr.io/stefanprodan/podinfo:6.7.1" "127.0.0.1:8889/stefanprodan/podinfo:6.7.1-zarf-2985051089" 2>&1 | tail -2

echo '=== force pull retries ==='
kubectl delete pods --all -n lab-sso-app --wait=false
sleep 15
kubectl get pods -n lab-sso-app --no-headers
echo REGISTRY_PUSH_DONE
