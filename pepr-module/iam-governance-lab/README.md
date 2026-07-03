# iam-governance-lab

A [Pepr](https://github.com/defenseunicorns/pepr) admission-control module (Pepr 1.2.2) that
enforces ownership and cost-center tagging on Deployments in the `lab-apps` namespace. It runs
on the `zarf-tutorial` k3d cluster in the `pepr-system` namespace (2 admission replicas).

## Design intent

This module ports two governance patterns I use daily in Entra ID / Intune onto Kubernetes:

- **Mutate** = a Conditional Access baseline auto-tagging a managed device on enrollment.
- **Validate** = an Intune compliance policy blocking enrollment when a required attribute
  is missing.

Same policy shape, different control plane: instead of evaluating device enrollments, the
webhook evaluates Deployment admissions.

## Rules (capabilities/iam-governance.ts)

**Mutate** — on every Deployment `IsCreatedOrUpdated` in `lab-apps`:

- always sets `governed-by=pepr-iam-policy`
- sets `owner=unassigned` if no `owner` label is present

**Validate** — on every Deployment `IsCreatedOrUpdated` in `lab-apps`:

- denies any Deployment missing a `cost-center` label, with exactly this message:

  > Deployments must carry a 'cost-center' label (governance baseline).

## Configuration highlights (package.json `pepr` block)

- `onError: reject` — fail closed. The generated webhooks use `failurePolicy: Fail`, so if the
  Pepr controller is unreachable, admissions in scope are denied rather than silently allowed.
- `rbacMode: scoped` — the generated ClusterRole (`pepr-iam-governance-lab`) holds only
  `pepr.dev/peprstores` (create/get/patch/watch) and
  `apiextensions.k8s.io/customresourcedefinitions` (create/patch). No wildcard rules.
- `webhookTimeout: 10` — 10-second admission webhook timeout.

## Build and deploy

```bash
npx pepr build
npx pepr deploy --yes   # run with kubectl context k3d-zarf-tutorial
```

`dist/` is gitignored — it contains a generated self-signed webhook TLS keypair — and is
recreated on every build.

## Testing (test-manifests/)

```bash
# Creates the lab-apps namespace and a compliant Deployment (cost-center=it-2740).
# Check it afterward: the mutate rule injects governed-by and owner labels.
kubectl apply -f test-manifests/lab-apps-and-compliant.yaml

# Non-compliant Deployment (no cost-center) — use a server-side dry run so the
# request hits the webhook without persisting anything. Expect the deny message above.
kubectl apply -f test-manifests/noncompliant.yaml --dry-run=server
```

## Where to see decisions

```bash
kubectl logs -n pepr-system deploy/pepr-iam-governance-lab
```

The controller logs each admission decision, including the structured deny for the
non-compliant Deployment (`allowed: false`, code 400).
