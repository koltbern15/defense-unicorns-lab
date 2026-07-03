# scripts/

This directory holds two kinds of scripts, and the distinction matters:

1. **Named scripts** — the curated runbook. These are the scripts you actually run to operate,
   verify, or repair the lab today. Promoted and cleaned up from the build log.
2. **Numbered scripts (`01`–`38`)** — the chronological build log of the lab (phases 0–8),
   preserved as-is. Dead ends and failed attempts are kept deliberately: the debugging
   journey is part of the artifact. Several are marked `HISTORICAL` in their comments
   because they reference one-time staging paths that no longer exist — read those for
   the record, don't run them.

## Execution assumptions

All scripts assume:

- WSL2 Ubuntu with Docker Desktop running
- Homebrew (linuxbrew) and nvm on `PATH` (most scripts source them explicitly)
- Two k3d clusters: `uds` (context `k3d-uds`) and `zarf-tutorial` (context `k3d-zarf-tutorial`)
- Run with bash: `bash scripts/<name>.sh`

Tunnels and the Lula UI do not survive a reboot — relaunch them (`keycloak-tunnel.sh`,
`launch-lula-ui.sh`) after any Docker Desktop or Windows restart. The clusters themselves
come back on their own.

## Curated runbook (named scripts)

| Script | Purpose | Cluster impact |
|---|---|---|
| `lab-status.sh` | Two-cluster health check: pods, packages, tunnels | Read-only |
| `seed-image-to-zarf-registry.sh` | The working fix for War Story 1: opens a `zarf connect registry` tunnel (port 8889), logs in with the push credential extracted at runtime from the `zarf-state` Secret, and copies a public image into the zarf-rewritten internal ref | Mutates (writes to internal registry, recreates pods) |
| `verify-sso-redirect.sh` | Polls `https://podinfo.uds.dev` until the unauthenticated 302 redirect to Keycloak appears | Read-only |
| `diagnose-sso-503.sh` | Hop-by-hop SSO trace: tenant gateway → waypoint → authservice → ztunnel | Read-only |
| `compare-waypoint-binding.sh` | Diffs waypoint labels between a known-working Service (keycloak) and the app Service — the diff that found War Story 2 | Read-only |
| `bind-service-to-waypoint.sh` | The War Story 2 fix: labels the Service with `istio.io/use-waypoint` + `istio.io/ingress-use-waypoint=true` so ingress traffic actually traverses the waypoint | Mutates (labels the Service) |
| `keycloak-tunnel.sh` | Background `uds zarf connect keycloak` tunnel on local port 8888 (used to reach the Welcome Page and register the first admin) | Read-only (local tunnel process only) |
| `launch-lula-ui.sh` | Starts the Lula 2 UI (via npx) on port 3000; from Windows browse to `http://[::1]:3000/` | Read-only (local process only) |

## Build log (numbered scripts 01–38)

Chronological record of building the lab. Kept unmodified, including the failures.

### Toolchain bootstrap (01–06)

| Script | Purpose |
|---|---|
| `01-node.sh` | Install Node 24 via nvm; print node/npm versions |
| `02-verify-node.sh` | Verify node/npm and git config; create the lab directory |
| `03-brew.sh` | Install Homebrew (linuxbrew) noninteractively and wire `shellenv` into `~/.profile` |
| `04-k3d-kubectl.sh` | Install k3d and a native Linux kubectl (replacing the Docker Desktop shim) |
| `05-zarf-uds.sh` | Install `zarf` and `uds` from the defenseunicorns Homebrew tap |
| `06-versions.sh` | Read-only version/path check for zarf, uds, k3d, kubectl |

### UDS Core deployment and access checks (07–10)

| Script | Purpose |
|---|---|
| `07-uds-deploy.sh` | Deploy UDS Core (`k3d-core-demo:latest`) via `uds deploy`, logging to `logs/uds-deploy.log` |
| `08-verify-core.sh` | Post-deploy health check: pod status summary, unhealthy pods, namespaces, `zarf connect` list |
| `09-connect-help.sh` | Explore `uds zarf connect --help`; list secrets in the keycloak and grafana namespaces |
| `10-access-check.sh` | Check connect shortcuts, k3d port mappings, gateway URL reachability, grafana secret keys, keycloak admin hints |

### Zarf: reference repos, demo package, building ArgoCD (11–16, 19)

| Script | Purpose |
|---|---|
| `11-clones.sh` | Shallow-clone reference repos (zarf tutorial, uds-core, uds-identity-config, lula) into `~/repos` |
| `12-dos-games.sh` | Deploy the dos-games demo zarf package from OCI (ghcr.io) and check its pods |
| `13-zarf-part1.sh` | Author the ArgoCD zarf package (`zarf.yaml` + `baseline-values.yaml`); run `zarf dev find-images` |
| `14-tutorial-cluster.sh` | Create the `zarf-tutorial` k3d cluster and run `zarf init --components=git-server` |
| `15-zarf-build.sh` | Append the discovered image list to `zarf.yaml`; build the package with `zarf package create` |
| `16-zarf-init-retry.sh` | Retry zarf init on the tutorial cluster after `zarf tools download-init` |
| `19-argocd-deploy.sh` | Deploy the self-built ArgoCD zarf package to the tutorial cluster. **HISTORICAL** — the init tarball was staged from the Windows side during the original build; on a fresh machine use `zarf tools download-init` |

### Maru recon and the Pepr module (17–18, 20–23, 28–29)

| Script | Purpose |
|---|---|
| `17-maru-phase7.sh` | Explore uds-core's maru task runner: `uds run --list`, `tasks.yaml`, keycloak-admin task search |
| `18-pepr-init-help.sh` | Print `npx pepr init --help` |
| `20-pepr-init.sh` | Scaffold the `iam-governance-lab` Pepr module with `npx pepr init` (error behavior: reject) |
| `21-pepr-wire.sh` | **HISTORICAL** — wire the capability file, `pepr.ts` entrypoint, and test manifests into the module from a one-time staging dir (files now live in `pepr-module/iam-governance-lab/`); format and build |
| `22-pepr-build-fix.sh` | Add `skipLibCheck` to tsconfig (dependency types clash with Node 24) and rebuild |
| `23-pepr-deploy-test.sh` | Deploy the Pepr module to `zarf-tutorial`; run the compliant/noncompliant admission tests |
| `28-pepr-fix.sh` | Exempt `pepr-system` from the zarf agent (`zarf.dev/agent=ignore`) and recreate pods to undo image-ref rewriting |
| `29-pepr-test.sh` | Re-run the admission tests: compliant deployment gets mutated labels, noncompliant is denied (exits 1 if `rogue-app` is admitted) |

### Recon, Keycloak tunnel, Lula exploration (24–27)

| Script | Purpose |
|---|---|
| `24-recon.sh` | Read-only recon of the cloned repos: keycloak admin docs/tasks in uds-core, uds-identity-config layout, lula samples |
| `25-keycloak-tunnel.sh` | Background `uds zarf connect keycloak` tunnel on port 8888. **SUPERSEDED** by the curated `keycloak-tunnel.sh` |
| `26-lula-help.sh` | Print `lula2` help and version via npx |
| `27-lula-format.sh` | Explore `lula2 ui --help`; search the lula repo for control-file format docs and sample YAML |

### SSO app (podinfo) and the image-seeding war story (30–37)

| Script | Purpose |
|---|---|
| `30-sso-docs.sh` | Read the uds-core SSO client registration doc; find example Package CRs using `enableAuthserviceSelector` |
| `31-sso-app.sh` | Apply the podinfo app + Package CR with the `sso` block, wait for reconcile, test the unauthenticated redirect. **HISTORICAL** — manifests were staged from a one-time dir; they now live in `uds-identity-notes/` |
| `32-sso-debug.sh` | Debug the podinfo Package: status, events, waypoint pods, operator (watcher) logs |
| `33-sso-fix.sh` | **SUPERSEDED / failed attempt** — re-enable the zarf agent on `lab-sso-app` and `zarf tools registry copy` straight to the NodePort ref |
| `34-registry-push.sh` | **SUPERSEDED / failed attempt** — registry tunnel (8889) + `zarf tools registry login` with the extracted push password + `registry copy`; the approach later refined into the working `seed-image-to-zarf-registry.sh` |
| `35-sso-final-fix.sh` | **SUPERSEDED / failed attempt** — copy the `private-registry` pull secret into the namespace and `docker pull/tag/push` through the tunnel |
| `36-image-import.sh` | **SUPERSEDED / failed attempt** — `k3d image import` of the rewritten ref into node containerd, plus a label nudge (which does not retrigger reconciliation — a spec change is required) |
| `37-pull-diag.sh` | Read-only pull diagnostics: image ref, pull policy, pull secrets, pod events, node containerd contents |

Scripts 33–36 are four attempts at the same problem — the three-layer podinfo
ImagePullBackOff (War Story 1). They are kept as history; **the working method is the
curated `seed-image-to-zarf-registry.sh`**. The full story (kubelet pull records on
k3s 1.35, the zarf checksum-tag rewrite, and the generation-bump requirement) is in the
repo's main README.

### Wrap-up (38)

| Script | Purpose |
|---|---|
| `38-wrapup-state.sh` | **HISTORICAL** — preserve scripts and notes into the repo from the original staging dir; snapshot running tunnels, clusters, folder tree, and kube context |
