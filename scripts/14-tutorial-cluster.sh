set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if ! k3d cluster list 2>/dev/null | grep -q zarf-tutorial; then
  k3d cluster create zarf-tutorial --wait 2>&1 | tail -3
fi
kubectl config use-context k3d-zarf-tutorial
kubectl cluster-info | head -2
zarf init --components=git-server --confirm > ~/projects/defense-unicorns-lab/logs/zarf-init-tutorial.log 2>&1
echo "ZARF_INIT_EXIT=$?"
tail -8 ~/projects/defense-unicorns-lab/logs/zarf-init-tutorial.log
echo TUTORIAL_CLUSTER_DONE
