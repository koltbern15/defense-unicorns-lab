#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
command -v zarf >/dev/null 2>&1 || brew install defenseunicorns/tap/zarf 2>&1 | tail -3
command -v uds >/dev/null 2>&1 || brew install defenseunicorns/tap/uds 2>&1 | tail -3
echo "--- versions ---"
zarf version
uds version
echo TOOLCHAIN_DONE
