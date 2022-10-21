import { ethers } from "hardhat";

async function roleControlDeploy(_admin: string) {
  const roleToken = await ethers.getContractFactory("TattoRole");
  const TattoRole = await roleToken.deploy(_admin);
  await TattoRole.deployed();

  console.log("admin address:", _admin);
  console.log("TattoRole address:", TattoRole.address);
  return TattoRole.address;
}

async function main() {
  await roleControlDeploy(process.env.ADMIN_ADDRESS);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
