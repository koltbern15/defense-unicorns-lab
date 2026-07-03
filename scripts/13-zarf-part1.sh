#!/usr/bin/env bash
set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
mkdir -p ~/projects/defense-unicorns-lab/zarf-packages/argocd
cd ~/projects/defense-unicorns-lab/zarf-packages/argocd

cat > zarf.yaml <<'EOF'
kind: ZarfPackageConfig
metadata:
  name: argocd
  version: 9.4.4
  description: |
    "A Zarf Package that deploys the ArgoCD platform"

components:
  - name: argocd
    description: |
      "Deploys the ArgoCD packaged chart into the cluster"
    required: true
    charts:
      - name: argo-cd
        version: 9.4.4
        namespace: argocd
        url: https://argoproj.github.io/argo-helm
        releaseName: argocd-baseline
        valuesFiles:
          - baseline-values.yaml
EOF

cat > baseline-values.yaml <<'EOF'
redis-ha:
  enabled: false

dex:
  enabled: false

notifications:
  enabled: false

redis:
  image:
    repository: docker.io/library/redis

server:
  service:
    labels:
      zarf.dev/connect-name: argocd
    annotations:
      zarf.dev/connect-description: "The Argocd UI service"
EOF

echo '=== running zarf dev find-images ==='
zarf dev find-images 2>/dev/null | tee find-images-output.yaml
echo PART1_AUTHORING_DONE
