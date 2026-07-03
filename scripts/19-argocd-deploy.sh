#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# HISTORICAL (build log): the zarf-init tarball was staged from the Windows side
# during the original build. On a fresh machine, fetch it instead:
#   zarf tools download-init   (or grab the matching release asset)
kubectl config use-context k3d-zarf-tutorial
cd ~/projects/defense-unicorns-lab/zarf-packages/argocd
zarf package deploy zarf-package-argocd-amd64-9.4.4.tar.zst --confirm > ~/projects/defense-unicorns-lab/logs/argocd-deploy.log 2>&1
echo "ARGOCD_DEPLOY_EXIT=$?"
tail -10 ~/projects/defense-unicorns-lab/logs/argocd-deploy.log
echo '=== argocd pods ==='
kubectl get pods -n argocd --no-headers
echo ARGOCD_DONE
