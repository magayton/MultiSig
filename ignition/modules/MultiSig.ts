import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// Constants to change for deployment 
const OWNERS: string[] = [];
const REQUIRED = 0;

const MultiSig = buildModule("MultiSig", (m) => {
  const owners = m.getParameter("_owners", OWNERS);
  const required = m.getParameter("_required", REQUIRED);

  const multiSig = m.contract("MultiSig", [owners, required]);

  return { multiSig };
});

export default MultiSig;
