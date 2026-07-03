#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
kubectl config use-context k3d-zarf-tutorial
MOD=~/projects/defense-unicorns-lab/pepr-module/iam-governance-lab
cd "$MOD"

echo '=== deploying pepr module ==='
npx pepr deploy --yes 2>&1 | tail -3
echo '=== waiting for pepr controllers ==='
for d in $(kubectl get deploy -n pepr-system -o name); do
  kubectl rollout status "$d" -n pepr-system --timeout=180s | tail -1
done
kubectl get pods -n pepr-system --no-headers

echo ''
echo '=== TEST 1: compliant deployment (has cost-center) ==='
kubectl apply -f test-manifests/lab-apps-and-compliant.yaml
sleep 2
echo '--- labels after admission (expect governed-by + owner added by mutate) ---'
kubectl get deploy compliant-app -n lab-apps -o jsonpath='{.metadata.labels}'
echo ''

echo ''
echo '=== TEST 2: noncompliant deployment (missing cost-center) ==='
if kubectl apply -f test-manifests/noncompliant.yaml 2> /tmp/deny.txt; then
  echo 'UNEXPECTED: rogue-app was ADMITTED'
else
  echo 'DENIED as expected. Webhook response:'
  cat /tmp/deny.txt
fi
echo ''
kubectl get deploy -n lab-apps --no-headers 2>/dev/null || true
echo PEPR_TEST_DONE
