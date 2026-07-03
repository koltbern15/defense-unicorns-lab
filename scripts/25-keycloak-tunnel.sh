#!/usr/bin/env bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if pgrep -f 'zarf connect keycloak' >/dev/null; then echo "tunnel already running"; exit 0; fi
cp ~/.kube/config /tmp/kubeconfig-uds
export KUBECONFIG=/tmp/kubeconfig-uds
kubectl config use-context k3d-uds >/dev/null
mkdir -p ~/projects/defense-unicorns-lab/logs
nohup uds zarf connect keycloak --local-port 8888 > ~/projects/defense-unicorns-lab/logs/keycloak-tunnel.log 2>&1 &
echo "tunnel pid: $!"
sleep 8
tail -2 ~/projects/defense-unicorns-lab/logs/keycloak-tunnel.log
curl -s -o /dev/null -w 'tunnel check from WSL: HTTP %{http_code}\n' --max-time 10 http://127.0.0.1:8888/
echo TUNNEL_SCRIPT_DONE
