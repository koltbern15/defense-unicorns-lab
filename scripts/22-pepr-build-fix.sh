#!/usr/bin/env bash
set -e
MOD=~/projects/defense-unicorns-lab/pepr-module/iam-governance-lab
cd "$MOD"
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# Add skipLibCheck to tsconfig (dependency types clash with Node 24's worker_threads)
node -e "
const fs = require('fs');
const t = JSON.parse(fs.readFileSync('tsconfig.json','utf8'));
t.compilerOptions.skipLibCheck = true;
fs.writeFileSync('tsconfig.json', JSON.stringify(t, null, 2));
console.log('skipLibCheck added');
"
npx pepr build 2>&1 | tail -4
echo '=== dist ==='
ls dist/
echo BUILD_FIX_DONE
