eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo '=== uds zarf connect help ==='
uds zarf connect --help 2>&1 | head -30
echo '=== keycloak ns secrets ==='
kubectl get secrets -n keycloak --no-headers | awk '{print $1}'
echo '=== grafana ns secrets ==='
kubectl get secrets -n grafana --no-headers | awk '{print $1}'
echo HELP_DONE
