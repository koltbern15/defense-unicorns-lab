#!/usr/bin/env bash
# seed-image-to-zarf-registry.sh — copy a public image into the zarf internal registry
# through a `zarf connect registry` tunnel (port 8889), authenticating with push creds
# extracted at runtime from the zarf-state Secret (never stored on disk).
# Assumes: WSL Ubuntu, brew/nvm on PATH, k3d clusters "uds" and "zarf-tutorial".
set -uo pipefail

# Historical example (the original hardcoded refs — War Story 1, podinfo ImagePullBackOff fix):
#   SRC: ghcr.io/stefanprodan/podinfo:6.7.1
#   DST: 127.0.0.1:8889/stefanprodan/podinfo:6.7.1-zarf-2985051089
# How to find the target ref: the zarf agent appends a checksum tag suffix when it
# rewrites image refs, so read the exact target from the failing pod spec, e.g.:
#   kubectl get pod <pod> -n <ns> -o jsonpath='{.spec.containers[0].image}'

if [ "$#" -ne 2 ]; then
  echo "Usage: $(basename "$0") <source-image-ref> <target-internal-registry-ref>" >&2
  echo "  e.g. $(basename "$0") ghcr.io/stefanprodan/podinfo:6.7.1 127.0.0.1:8889/stefanprodan/podinfo:6.7.1-zarf-<checksum>" >&2
  exit 1
fi
SRC="$1"
DST="$2"
CTX="--context k3d-uds"

command -v zarf >/dev/null || eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
command -v zarf >/dev/null || { echo "FATAL: zarf not on PATH"; exit 1; }

echo "=== [1/4] restart registry tunnel on 8889 ==="
pkill -f 'zarf connect registry' 2>/dev/null && sleep 2
nohup setsid zarf connect registry --local-port 8889 </dev/null >/tmp/registry-tunnel.log 2>&1 &
for i in $(seq 1 12); do
  sleep 2
  if curl -s -o /dev/null --max-time 3 http://127.0.0.1:8889/v2/ </dev/null; then TUN=1; break; fi
done
[ "${TUN:-0}" = "1" ] || { echo "FATAL: tunnel not responding"; cat /tmp/registry-tunnel.log; exit 1; }
echo "tunnel up on 8889"

echo
echo "=== [2/4] extract zarf-push password (not printed) ==="
PW=$(kubectl $CTX get secret -n zarf zarf-state -o jsonpath='{.data.state}' </dev/null | base64 -d \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["registryInfo"]["pushPassword"])')
[ -n "$PW" ] || { echo "FATAL: no pushPassword"; exit 1; }

echo
echo "=== [3/4] crane login + copy (full multi-arch index from source) ==="
zarf tools registry login 127.0.0.1:8889 -u zarf-push -p "$PW" </dev/null 2>&1 | tail -1
zarf tools registry copy "$SRC" "$DST" --insecure </dev/null 2>&1 | tail -4

echo
echo "=== [4/4] verify tag exists in registry ==="
DST_REPO="${DST#*/}"       # strip registry host
DST_REPO="${DST_REPO%:*}"  # strip tag
curl -s -u "zarf-push:$PW" "http://127.0.0.1:8889/v2/${DST_REPO}/tags/list" </dev/null
echo
