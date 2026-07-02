set -e
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
echo "node: $(node --version)"
echo "npm: $(npm --version)"
echo "which node: $(which node)"
git config --global user.name || true
git config --global user.email || true
mkdir -p ~/projects/defense-unicorns-lab
echo LAB_DIR_OK
