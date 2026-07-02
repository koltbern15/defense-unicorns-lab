import { Capability, a } from "pepr";

/**
 * IAM Governance capability.
 *
 * Mirrors the governance patterns used in Entra ID / Intune:
 *  - Mutate  = Conditional Access baseline auto-tagging a managed device on enrollment
 *  - Validate = Intune compliance policy blocking enrollment when a required
 *               attribute is missing
 *
 * Expressed here as a Kubernetes admission webhook over Deployments in lab-apps.
 */
export const IAMGovernance = new Capability({
  name: "iam-governance",
  description:
    "Enforces ownership and cost-center tagging on workloads — mirrors Conditional Access / Intune compliance-tagging patterns from Entra ID",
  namespaces: ["lab-apps"],
});

const { When } = IAMGovernance;

// Auto-tag every deployment, the way a Conditional Access baseline
// auto-tags a managed device on enrollment.
When(a.Deployment)
  .IsCreatedOrUpdated()
  .InNamespace("lab-apps")
  .Mutate(request => {
    request.SetLabel("governed-by", "pepr-iam-policy");
    if (!request.Raw.metadata?.labels?.["owner"]) {
      request.SetLabel("owner", "unassigned");
    }
  });

// Deny anything missing a cost-center label — same idea as blocking
// enrollment on a device missing a required compliance attribute.
When(a.Deployment)
  .IsCreatedOrUpdated()
  .InNamespace("lab-apps")
  .Validate(request => {
    if (!request.HasLabel("cost-center")) {
      return request.Deny(
        "Deployments must carry a 'cost-center' label (governance baseline).",
      );
    }
    return request.Approve();
  });
