set -e
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
cd ~/projects/defense-unicorns-lab/zarf-packages/argocd

cat >> zarf.yaml <<'EOF'
    images:
      - docker.io/library/redis:8.2.3-alpine
      - quay.io/argoproj/argocd:v3.3.2
      # Cosign artifacts for images - argocd
      - quay.io/argoproj/argocd:sha256-5882f28f7aaeaac397949c4511fdc1ad66c1260af44166ccf7e57aca3d7b9797.att
EOF

echo '=== final zarf.yaml ==='
cat zarf.yaml
echo '=== building package ==='
zarf package create . --confirm > ~/projects/defense-unicorns-lab/logs/zarf-package-create.log 2>&1
echo "CREATE_EXIT=$?"
tail -5 ~/projects/defense-unicorns-lab/logs/zarf-package-create.log
ls -lh *.tar.zst
echo BUILD_DONE
