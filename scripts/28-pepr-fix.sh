set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-zarf-tutorial >/dev/null
echo '=== confirm image rewrite by zarf agent ==='
kubectl get pods -n pepr-system -o jsonpath='{.items[0].spec.containers[0].image}'
echo ''
echo '=== fix: exempt pepr-system from zarf agent, recreate pods ==='
kubectl label ns pepr-system zarf.dev/agent=ignore --overwrite
kubectl delete pods -n pepr-system --all --wait=false
kubectl rollout status deploy/pepr-iam-governance-lab -n pepr-system --timeout=240s | tail -1
kubectl rollout status deploy/pepr-iam-governance-lab-watcher -n pepr-system --timeout=240s 2>/dev/null | tail -1 || true
kubectl get pods -n pepr-system --no-headers
echo '=== new image ref ==='
kubectl get pods -n pepr-system -o jsonpath='{.items[0].spec.containers[0].image}'
echo ''
echo PEPR_FIX_DONE
