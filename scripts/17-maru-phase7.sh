eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
cd ~/repos/uds-core
echo '=== uds run --list ==='
uds run --list 2>&1 | head -30
echo '=== tasks.yaml (first 40 lines) ==='
head -40 tasks.yaml
echo '=== keycloak admin task search ==='
grep -rn 'keycloak-admin' tasks/ tasks.yaml 2>/dev/null | head -5
echo PHASE7_DONE
