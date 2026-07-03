#!/usr/bin/env bash
set -e
if ! command -v k3d >/dev/null 2>&1; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi
k3d version
if ! command -v kubectl >/dev/null 2>&1 || [ "$(command -v kubectl)" = "/mnt/c/Program Files/Docker/Docker/resources/bin/kubectl" ]; then
  cd /tmp
  curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
fi
kubectl version --client
echo K3D_KUBECTL_DONE
