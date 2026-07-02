import { PeprModule } from "pepr";
// cfg loads your pepr configuration from package.json
import cfg from "./package.json";

import { IAMGovernance } from "./capabilities/iam-governance";

/**
 * Entrypoint for the iam-governance-lab Pepr module.
 */
new PeprModule(cfg, [IAMGovernance]);
