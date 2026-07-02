eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo '=== preserve scripts into lab folder ==='
SP="/mnt/c/Users/ktber/AppData/Local/Temp/claude/C--Users-ktber-projects-Defense-Unicorns/c435975b-423c-4956-9563-a8ecdbf6d5eb/scratchpad"
mkdir -p ~/projects/defense-unicorns-lab/scripts ~/projects/defense-unicorns-lab/uds-identity-notes
for f in "$SP"/wsl-scripts/*.sh; do tr -d '\r' < "$f" > ~/projects/defense-unicorns-lab/scripts/"$(basename "$f")"; done
for f in "$SP"/pepr-files/*; do tr -d '\r' < "$f" > ~/projects/defense-unicorns-lab/uds-identity-notes/"$(basename "$f")"; done
ls ~/projects/defense-unicorns-lab/scripts | wc -l
echo '=== running tunnels ==='
pgrep -af 'zarf connect' || echo 'no tunnels running'
echo '=== k3d clusters ==='
k3d cluster list
echo '=== lab folder tree (top level) ==='
find ~/projects/defense-unicorns-lab -maxdepth 2 -not -path '*/node_modules*' -not -path '*/.git*' | head -25
echo '=== current kube context ==='
kubectl config current-context
echo WRAPUP_STATE_DONE
