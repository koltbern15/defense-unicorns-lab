set -e
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
cd ~/projects/defense-unicorns-lab
rm -rf pepr-module/iam-governance-lab
mkdir -p pepr-module && cd pepr-module
npx --yes pepr init \
  --name iam-governance-lab \
  --uuid iam-governance-lab \
  --description "IAM governance policies mirroring Entra ID Conditional Access patterns - Defense Unicorns practice lab" \
  --error-behavior reject \
  --yes < /dev/null 2>&1 | tail -6
echo '=== module contents ==='
ls iam-governance-lab
echo PEPR_INIT_DONE
