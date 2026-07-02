eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo '=== pod status summary ==='
kubectl get pods -A --no-headers | awk '{print $4}' | sort | uniq -c
echo '=== pods NOT Running/Completed ==='
kubectl get pods -A --no-headers | grep -v -E 'Running|Completed' || echo ALL_HEALTHY
echo '=== namespaces ==='
kubectl get ns --no-headers | awk '{print $1}' | tr '\n' ' '
echo ''
echo '=== connect list ==='
uds zarf connect --list 2>&1 | tail -20
echo VERIFY_DONE
