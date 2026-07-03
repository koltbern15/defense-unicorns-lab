#!/usr/bin/env bash
# launch-lula-ui.sh — launch the Lula 2 UI detached on :3000 with the lab's
# lula-workspace dir, then poll until it answers (or dump the log and fail).
# Assumes: WSL Ubuntu with brew/nvm on PATH; k3d clusters "uds" and "zarf-tutorial".
# Relaunch after any reboot — the UI does not survive Docker Desktop restarts.
set -uo pipefail
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

WS=~/projects/defense-unicorns-lab/lula-workspace
mkdir -p "$WS"

echo "=== launch lula2 ui (detached) ==="
pkill -f 'lula2 ui' 2>/dev/null && sleep 2
cd "$WS"
mkdir -p ~/projects/defense-unicorns-lab/logs
nohup setsid npx --yes lula2 ui --dir "$WS" --port 3000 --no-open-browser </dev/null > ~/projects/defense-unicorns-lab/logs/lula-ui.log 2>&1 &
for i in $(seq 1 20); do
  sleep 3
  CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1:3000/ </dev/null || true)
  [ "$CODE" != "000" ] && [ -n "$CODE" ] && break
done
echo "http://127.0.0.1:3000/ -> HTTP $CODE (from Ubuntu)"
if [ "$CODE" = "000" ] || [ -z "$CODE" ]; then
  echo "FATAL — log tail:"; tail -15 ~/projects/defense-unicorns-lab/logs/lula-ui.log; exit 1
fi

echo
echo "=== log tail (startup) ==="
tail -5 ~/projects/defense-unicorns-lab/logs/lula-ui.log
