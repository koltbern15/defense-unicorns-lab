eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
mkdir -p ~/projects/defense-unicorns-lab/logs
zarf package deploy oci://ghcr.io/zarf-dev/packages/dos-games:1.3.0 --key=https://zarf.dev/cosign.pub --confirm > ~/projects/defense-unicorns-lab/logs/dos-games-deploy.log 2>&1
rc=$?
echo "DOS_GAMES_EXIT=$rc"
tail -15 ~/projects/defense-unicorns-lab/logs/dos-games-deploy.log
echo '=== dos-games pods ==='
kubectl get pods -n dos-games -o wide 2>&1
kubectl get events -n dos-games --sort-by=.lastTimestamp 2>/dev/null | tail -8
