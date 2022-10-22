import { ethers } from "hardhat";

async function marketDeploy(roleAddress: string, currencyAddress: string) {
  const marketToken = await ethers.getContractFactory("TattoMarket");
  const TattoMarket = await marketToken.deploy(roleAddress, currencyAddress);
  await TattoMarket.deployed();

  console.log("TattoMarket address:", TattoMarket.address);
  return TattoMarket.address;
}

async function main() {
  await marketDeploy(process.env.ROLE_ADDRESS, process.env.CURRENCY_ADDRESS);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
