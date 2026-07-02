set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-zarf-tutorial >/dev/null
MOD=~/projects/defense-unicorns-lab/pepr-module/iam-governance-lab
cd "$MOD"

echo '=== TEST 1: compliant deployment (has cost-center) ==='
kubectl apply -f test-manifests/lab-apps-and-compliant.yaml
sleep 3
echo '--- labels after admission (expect governed-by + owner added by mutate) ---'
kubectl get deploy compliant-app -n lab-apps -o jsonpath='{.metadata.labels}'
echo ''
kubectl get pods -n lab-apps --no-headers

echo ''
echo '=== TEST 2: noncompliant deployment (missing cost-center) ==='
if kubectl apply -f test-manifests/noncompliant.yaml 2> /tmp/deny.txt; then
  echo 'UNEXPECTED: rogue-app was ADMITTED'
  exit 1
else
  echo 'DENIED as expected. Webhook response:'
  cat /tmp/deny.txt
fi
echo ''
echo '=== final state of lab-apps ==='
kubectl get deploy -n lab-apps --no-headers 2>/dev/null || echo 'only compliant-app should be listed'
echo PEPR_TEST_PASS
