import { ethers } from "hardhat";

async function marketDeploy(
  roleAddress: string,
  currencyAddress: string,
  backAddress: string
) {
  const marketToken = await ethers.getContractFactory("TattoMarket");
  const TattoMarket = await marketToken.deploy(
    roleAddress,
    currencyAddress,
    backAddress
  );
  await TattoMarket.deployed();

  console.log("TattoMarket address:", TattoMarket.address);
  return TattoMarket.address;
}

async function main() {
  await marketDeploy(
    process.env.ROLE_ADDRESS,
    process.env.CURRENCY_ADDRESS,
    process.env.BACK_ADDRESS
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
