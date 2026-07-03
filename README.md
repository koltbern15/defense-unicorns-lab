# Defense Unicorns Lab — Interview Prep Build

A hands-on Kubernetes security and governance lab built with **UDS Core**, **Zarf**, **Pepr**, and **Keycloak** for demonstrating cloud-native zero-trust principles in action.

## Overview

This lab implements a complete cloud-native security stack. It demonstrates:

- Air-gap deployment via Zarf package management and internal registry
- Identity and SSO via Keycloak OIDC and Package CR declarative wiring
- Zero-trust networking via Istio Ambient mTLS and AuthorizationPolicy
- Admission control and governance via Pepr webhooks (mutate + validate)
- Compliance attestation via Lula 2 control framework (NIST AC family)

## Architecture

### Infrastructure

| Component | Version | Role |
|-----------|---------|------|
| k3s | v1.35.5 | Kubernetes engine (via k3d) |
| UDS Core | v1.7 | Ambient Istio, Keycloak, Authservice |
| Zarf | v0.80.0 | Air-gap package management |
| Pepr | v1.2.2 | Admission webhooks |
| Keycloak | latest | OIDC identity provider |
| Lula 2 | v0.9.5 | Compliance framework |

### Clusters

- **k3d-uds**: UDS Core v1.7 + lab workloads (podinfo with OIDC)
- **k3d-zarf-tutorial**: Zarf-init'd ArgoCD + Pepr module

## Lab Phases (Completed)

- Phase 0: Environment setup (WSL2 Ubuntu, Docker Desktop)
- Phase 1: Toolchain (zarf, uds-cli, k3d, kubectl, Node, pepr, lula2)
- Phase 2: UDS Core deployment (45 pods, Keycloak, Grafana)
- Phase 3: Zarf package & ArgoCD tutorial (210MB tarball with SBOM)
- Phase 4: Pepr admission policy (mutate baseline tags, validate cost-center)
- Phase 5: Package CR SSO wiring (podinfo OIDC; 302 redirect verified)
- Phase 6: Control Narratives (AC-2, AC-3, AC-6, AC-17 with evidence)

## Quick Start

Prerequisites: Windows 11 + WSL2 (Ubuntu 26.04), Docker Desktop, 16GB RAM

Bring up infrastructure:
```
cd ~/projects/defense-unicorns-lab
k3d cluster start uds
k3d cluster start zarf-tutorial
bash scripts/25-keycloak-tunnel.sh
kubectl config use-context k3d-uds
```

Access services:
- Keycloak Admin: http://127.0.0.1:8888 (register first admin)
- Podinfo (SSO): https://podinfo.uds.dev (302 → Keycloak OIDC)
- Grafana: https://grafana.admin.uds.dev

Note: the Quick Start assumes the clusters already exist locally — they were
built in Phases 0-3 (see the numbered scripts and scripts/README.md). This
repo is the record of a built lab, not a one-command installer.

## File Structure

```
defense-unicorns-lab/
├── README.md
├── LICENSE
├── scripts/                          (46 utilities — see scripts/README.md)
├── lula-workspace/fake-controls/     (13 NIST AC controls; 4 with narratives)
├── pepr-module/iam-governance-lab/   (admission policy source)
├── uds-identity-notes/               (podinfo workload + Package CR manifests)
└── zarf-packages/argocd/             (zarf.yaml + values; tarball built locally)
```

Local-only, intentionally not in the repo (gitignored): logs/, built package
tarballs (the 210MB ArgoCD .tar.zst rebuilds with scripts/15-zarf-build.sh),
pepr dist/ output, and node_modules/.

## Control Narratives (Phase 6)

Four NIST AC family controls with real lab evidence:

- AC-2.1: Account Management (Keycloak OIDC client auto-provisioning)
- AC-3.1: Access Enforcement (Istio AuthorizationPolicy + Authservice)
- AC-6.1: Least Privilege (Pepr admission control tagging baseline)
- AC-17.1: Remote Access (OIDC token lifecycle + mTLS)

See: lula-workspace/fake-controls/controls/AC/

## Interview Talking Points

**Defensible Claims**:
- "I deployed UDS Core v1.7 on k3d and verified the Keycloak OIDC challenge flow — 302 redirect with PKCE at the gateway, confirmed in the Envoy access logs."
- "I built a Zarf ArgoCD package from scratch (210MB tarball with SBOM)."
- "I wrote a Pepr admission policy enforcing governance tagging."
- "I fixed k3s 1.35 kubelet image resolution using Zarf's internal registry."
- "The UDS Operator auto-provisioned Keycloak OIDC clients and Istio policies."

**Open Questions**:
- How do teams handle bring-your-own public images in UDS?
- Waypoint-per-Package model in Ambient — how does this scale?
- Does UDS Operator reconcile drift if Keycloak client is edited directly?

## Known Fixes

1. k3s 1.35 kubelet refuses locally-tagged images → Use zarf tools registry copy
2. UDS Operator reconciliation requires spec changes (not labels)
3. Waypoint labeling on Service (not just Pod)
4. Docker socket drop on WSL restart → Restart Docker Desktop
5. WSL cross-shell scripting → Use bash <(tr -d '\r' < script.sh) pattern

## How This Was Built

I designed, drove, and operated this lab, working with Claude Code
(Anthropic's CLI agent) as an infrastructure pair-programmer. The division of
labor was deliberate: I set the goals and phases, made the architecture calls,
did the hands-on work (Keycloak, the Lula control workspace, verification at
every step), and decided what was true enough to publish. Claude accelerated
the mechanical side — scripting, log archaeology, and running down parallel
debugging paths.

Two things worth knowing about the process:

- The debugging was real. The three-layer ImagePullBackOff fix (k3s 1.35
  kubelet image-resolution semantics → seeding the Zarf internal registry) and
  the waypoint Service-labeling gap in Known Fixes were diagnosed against live
  clusters, not copied from docs.
- Before publishing, every compliance narrative in lula-workspace/ was
  adversarially audited against the running clusters. Claims that couldn't be
  reproduced with a command were rewritten or marked pending — and one finding
  (the Pepr controller running with default admin RBAC while the AC-6
  narrative claimed least privilege) was fixed in the infrastructure itself
  (rbacMode: scoped), not papered over in the narrative.

Every claim in the control narratives is reproducible with the commands cited
in their evidence sections.

## Built By

Kolton Bernhardt, 2026-07-01. Personal interview prep lab.

See lula-workspace/fake-controls/controls/AC/ for compliance narratives.
