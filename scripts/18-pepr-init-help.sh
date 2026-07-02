set -e
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
echo "using node: $(which node) $(node --version)"
npx --yes pepr init --help 2>&1 | head -40
echo PEPR_HELP_DONE
