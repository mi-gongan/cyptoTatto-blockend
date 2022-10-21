import { ethers } from "hardhat";

async function currencyControlDeploy(_role: string) {
  const currencyToken = await ethers.getContractFactory("TattoCurrency");
  const TattoCurrency = await currencyToken.deploy(_role);
  await TattoCurrency.deployed();

  console.log("TattoCurrency address:", TattoCurrency.address);
  return TattoCurrency.address;
}

async function main() {
  await currencyControlDeploy(process.env.ROLE_ADDRESS);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
