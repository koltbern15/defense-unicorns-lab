set -e
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
npx lula2 ui --help 2>&1 | head -20
echo '=== lula repo docs on file format ==='
ls ~/repos/lula/docs 2>/dev/null | head -10
grep -rln 'control-set\|controlSet\|control_set' ~/repos/lula/docs 2>/dev/null | head -5
echo '=== sample yaml in repo (if any) ==='
find ~/repos/lula -name '*.yaml' -path '*control*' -not -path '*/node_modules/*' -not -path '*/.git/*' | head -8
find ~/repos/lula -name '*.yaml' -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.github/*' | head -15
echo FORMAT_DONE
