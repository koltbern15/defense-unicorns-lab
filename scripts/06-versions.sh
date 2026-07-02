eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "zarf path: $(command -v zarf)"
zarf version 2>/dev/null
echo "uds path: $(command -v uds)"
uds version 2>/dev/null
echo "k3d: $(k3d version | head -1)"
echo "kubectl: $(kubectl version --client 2>/dev/null | head -1)"
echo VERSIONS_DONE
