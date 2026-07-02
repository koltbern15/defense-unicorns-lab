set -e
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install 24 2>&1 | tail -2
echo "node: $(node --version)"
echo "npm: $(npm --version)"
echo "which node: $(which node)"
