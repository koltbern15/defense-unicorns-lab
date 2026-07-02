set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
SP="/mnt/c/Users/ktber/AppData/Local/Temp/claude/C--Users-ktber-projects-Defense-Unicorns/c435975b-423c-4956-9563-a8ecdbf6d5eb/scratchpad/pepr-files"
kubectl config use-context k3d-uds >/dev/null
mkdir -p ~/projects/defense-unicorns-lab/uds-identity-notes
tr -d '\r' < "$SP/podinfo-app.yaml" > ~/projects/defense-unicorns-lab/uds-identity-notes/podinfo-app.yaml
tr -d '\r' < "$SP/podinfo-package-cr.yaml" > ~/projects/defense-unicorns-lab/uds-identity-notes/podinfo-package-cr.yaml

echo '=== apply app + Package CR ==='
kubectl apply -f ~/projects/defense-unicorns-lab/uds-identity-notes/podinfo-app.yaml
kubectl apply -f ~/projects/defense-unicorns-lab/uds-identity-notes/podinfo-package-cr.yaml

echo '=== wait for Package to reconcile ==='
for i in $(seq 1 30); do
  phase=$(kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status.phase}' 2>/dev/null)
  [ "$phase" = "Ready" ] && break
  sleep 5
done
echo "package phase: $phase"
kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status.ssoClients}' 2>/dev/null; echo ''

echo '=== pod ==='
kubectl rollout status deploy/podinfo -n lab-sso-app --timeout=180s | tail -1
echo '=== operator-created SSO client secret ==='
kubectl get secret -n lab-sso-app --no-headers
echo '=== istio AuthorizationPolicies created by operator ==='
kubectl get authorizationpolicy -n lab-sso-app --no-headers 2>/dev/null || echo none
echo '=== the Conditional Access moment: unauthenticated request ==='
code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 15 https://podinfo.uds.dev/)
loc=$(curl -sk -o /dev/null -w '%{redirect_url}' --max-time 15 https://podinfo.uds.dev/)
echo "GET https://podinfo.uds.dev -> HTTP $code redirect: $loc"
echo SSO_APP_DONE
