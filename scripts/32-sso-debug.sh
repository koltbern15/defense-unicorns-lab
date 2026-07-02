eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null
echo '=== package status ==='
kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status}' | head -c 1500; echo ''
echo '=== events ==='
kubectl get events -n lab-sso-app --sort-by=.lastTimestamp | tail -6
echo '=== pods in ns (waypoint?) ==='
kubectl get pods -n lab-sso-app --no-headers
echo '=== operator logs mentioning podinfo ==='
for p in $(kubectl get pods -n pepr-system -o name | grep watcher); do
  kubectl logs "$p" -n pepr-system --since=15m 2>/dev/null | grep -i -E 'podinfo|lab-sso' | tail -8
done
echo DEBUG_DONE
