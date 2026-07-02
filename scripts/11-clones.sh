set -e
mkdir -p ~/repos
cd ~/repos
for r in zarf-dev/tutorial defenseunicorns/uds-core defenseunicorns/uds-identity-config defenseunicorns/lula; do
  d=$(basename $r)
  if [ -d "$d/.git" ]; then echo "$d already cloned"; else git clone --depth 1 -q https://github.com/$r.git && echo "cloned $d"; fi
done
ls ~/repos
echo CLONES_DONE
