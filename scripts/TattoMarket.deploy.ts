import { ethers } from "hardhat";

async function marketDeploy(currencyAddress: string) {
  const marketToken = await ethers.getContractFactory("TattoMarket");
  const TattoMarket = await marketToken.deploy(currencyAddress);
  await TattoMarket.deployed();

  console.log("TattoMarket address:", TattoMarket.address);
  return TattoMarket.address;
}

async function main() {
  await marketDeploy(process.env.CURRENCY_ADDRESS);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
