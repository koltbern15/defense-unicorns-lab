echo '=== register-and-customize-sso-clients.mdx (first 80 lines) ==='
sed -n '1,80p' ~/repos/uds-core/docs/how-to-guides/identity-and-authorization/register-and-customize-sso-clients.mdx
echo ''
echo '=== example Package CRs with sso in repo ==='
grep -rln 'enableAuthserviceSelector' ~/repos/uds-core/src --include='*.yaml' | head -5
echo SSO_DOCS_DONE
