echo '=== keycloak admin docs in uds-core ==='
grep -rln 'admin' ~/repos/uds-core/docs 2>/dev/null | grep -i -E 'keycloak|idam|identity' | head -5
grep -rn -i 'admin user' ~/repos/uds-core/docs 2>/dev/null | head -8
echo ''
echo '=== keycloak setup tasks in uds-core src ==='
ls ~/repos/uds-core/src/keycloak/tasks 2>/dev/null || find ~/repos/uds-core/src/keycloak -maxdepth 1 -type f -o -maxdepth 1 -type d 2>/dev/null | head
grep -rn -i 'admin' ~/repos/uds-core/src/keycloak/tasks.yaml 2>/dev/null | head -5
echo ''
echo '=== uds-identity-config structure ==='
find ~/repos/uds-identity-config -maxdepth 2 -type d | grep -v .git | head -15
echo ''
echo '=== lula repo: samples + package.json ==='
ls ~/repos/lula/samples 2>/dev/null
grep -E '"name"|"version"|"bin"' ~/repos/lula/package.json 2>/dev/null | head -5
echo RECON_DONE
