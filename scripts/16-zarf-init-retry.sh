#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
kubectl config use-context k3d-zarf-tutorial
zarf tools download-init 2>&1 | tail -2
zarf init --components=git-server --confirm > ~/projects/defense-unicorns-lab/logs/zarf-init-tutorial.log 2>&1
echo "ZARF_INIT_EXIT=$?"
tail -6 ~/projects/defense-unicorns-lab/logs/zarf-init-tutorial.log
kubectl get pods -n zarf --no-headers
echo INIT_RETRY_DONE
