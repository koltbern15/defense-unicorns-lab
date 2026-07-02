set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-uds >/dev/null

echo '=== 1. copy private-registry secret into lab-sso-app ==='
kubectl get secret private-registry -n keycloak -o json \
  | sed 's/"namespace": "keycloak"/"namespace": "lab-sso-app"/' \
  | kubectl apply -f - 2>&1 | tail -1

echo '=== 2. push podinfo image via docker through the tunnel ==='
pgrep -f 'zarf connect registry' >/dev/null || { nohup zarf connect registry --local-port 8889 > /tmp/registry-tunnel.log 2>&1 & sleep 8; }
PUSH_PASS=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | grep -o '"pushPassword":"[^"]*"' | cut -d'"' -f4)
docker pull -q ghcr.io/stefanprodan/podinfo:6.7.1
docker tag ghcr.io/stefanprodan/podinfo:6.7.1 127.0.0.1:8889/stefanprodan/podinfo:6.7.1-zarf-2985051089
echo "$PUSH_PASS" | docker login 127.0.0.1:8889 -u zarf-push --password-stdin 2>&1 | tail -1
docker push 127.0.0.1:8889/stefanprodan/podinfo:6.7.1-zarf-2985051089 2>&1 | tail -2

echo '=== 3. recreate pods ==='
kubectl delete pods --all -n lab-sso-app --wait=false
kubectl rollout status deploy/podinfo -n lab-sso-app --timeout=240s | tail -1

echo '=== 4. wait for package Ready ==='
phase=""
for i in $(seq 1 36); do
  phase=$(kubectl get package podinfo -n lab-sso-app -o jsonpath='{.status.phase}' 2>/dev/null)
  [ "$phase" = "Ready" ] && break
  sleep 5
done
echo "package phase: $phase"
kubectl get pods -n lab-sso-app --no-headers

echo '=== 5. the Conditional Access moment ==='
code=$(curl -sk -o /dev/null -w '%{http_code}' --max-time 15 https://podinfo.uds.dev/)
loc=$(curl -sk -o /dev/null -w '%{redirect_url}' --max-time 15 https://podinfo.uds.dev/)
echo "GET https://podinfo.uds.dev -> HTTP $code"
echo "redirects to: $loc"
echo FINAL_FIX_DONE
