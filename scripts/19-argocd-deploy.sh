set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
mv -f "/mnt/c/Users/ktber/projects/Defense Unicorns/zarf-init-amd64-v0.80.0.tar.zst" ~/projects/defense-unicorns-lab/zarf-packages/ 2>/dev/null && echo "moved init tarball" || echo "init tarball not in Windows folder"
kubectl config use-context k3d-zarf-tutorial
cd ~/projects/defense-unicorns-lab/zarf-packages/argocd
zarf package deploy zarf-package-argocd-amd64-9.4.4.tar.zst --confirm > ~/projects/defense-unicorns-lab/logs/argocd-deploy.log 2>&1
echo "ARGOCD_DEPLOY_EXIT=$?"
tail -10 ~/projects/defense-unicorns-lab/logs/argocd-deploy.log
echo '=== argocd pods ==='
kubectl get pods -n argocd --no-headers
echo ARGOCD_DONE
