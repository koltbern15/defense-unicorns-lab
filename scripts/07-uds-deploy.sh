eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
mkdir -p ~/projects/defense-unicorns-lab/logs
cd ~/projects/defense-unicorns-lab
uds deploy k3d-core-demo:latest --confirm --no-progress > ~/projects/defense-unicorns-lab/logs/uds-deploy.log 2>&1
rc=$?
echo "UDS_DEPLOY_EXIT=$rc"
echo "--- last 30 log lines ---"
tail -30 ~/projects/defense-unicorns-lab/logs/uds-deploy.log
