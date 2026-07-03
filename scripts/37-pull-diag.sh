#!/usr/bin/env bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null
echo '--- image ref ---'
kubectl get pod -n lab-sso-app -l app=podinfo -o jsonpath='{.items[0].spec.containers[0].image}'
echo ''
echo '--- pull policy ---'
kubectl get pod -n lab-sso-app -l app=podinfo -o jsonpath='{.items[0].spec.containers[0].imagePullPolicy}'
echo ''
echo '--- pull secrets ---'
kubectl get pod -n lab-sso-app -l app=podinfo -o jsonpath='{.items[0].spec.imagePullSecrets}'
echo ''
echo '--- events ---'
kubectl describe pod -n lab-sso-app -l app=podinfo | tail -6
echo '--- what does the node containerd have? ---'
docker exec k3d-uds-server-0 crictl images 2>/dev/null | grep -i podinfo || echo 'podinfo NOT in node containerd'
echo DIAG_DONE
