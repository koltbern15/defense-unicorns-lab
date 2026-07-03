#!/usr/bin/env bash
set -e
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
cd ~/projects/defense-unicorns-lab
npx --yes lula2 --help 2>&1 | head -40
echo '=== version ==='
npx lula2 --version 2>&1 | tail -1
echo LULA_HELP_DONE
