#!/usr/bin/env bash
set -e
# HISTORICAL (build log): sources were staged from a one-time local dir during the
# original build; they now live in this repo under pepr-module/iam-governance-lab/.
SP="/path/to/local-staging/pepr-files"  # original staging dir (removed for publication)
MOD=~/projects/defense-unicorns-lab/pepr-module/iam-governance-lab

tr -d '\r' < "$SP/iam-governance.ts" > "$MOD/capabilities/iam-governance.ts"
rm -f "$MOD/capabilities/hello-pepr.ts" "$MOD/capabilities/hello-pepr.samples.yaml"

cat > "$MOD/pepr.ts" <<'EOF'
import { PeprModule } from "pepr";
// cfg loads your pepr configuration from package.json
import cfg from "./package.json";

import { IAMGovernance } from "./capabilities/iam-governance";

/**
 * Entrypoint for the iam-governance-lab Pepr module.
 */
new PeprModule(cfg, [IAMGovernance]);
EOF

mkdir -p "$MOD/test-manifests"
tr -d '\r' < "$SP/test-manifests.yaml" > "$MOD/test-manifests/lab-apps-and-compliant.yaml"
tr -d '\r' < "$SP/noncompliant.yaml" > "$MOD/test-manifests/noncompliant.yaml"

cd "$MOD"
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
echo '=== format check / build ==='
npx pepr format > /dev/null 2>&1 || true
npx pepr build 2>&1 | tail -4
ls dist/ | head
echo PEPR_WIRE_DONE
