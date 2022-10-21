import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";

describe("market", function () {
  async function deployMarket() {
    const [admin, user] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin);
    await TattoRole.deployed();

    const currencyToken = await ethers.getContractFactory("TattoCurrency");
    const TattoCurrency = await currencyToken.deploy(TattoRole.address);
    await TattoCurrency.deployed();

    const marketyToken = await ethers.getContractFactory("TattoMarket");
    const TattoMarket = await marketyToken.deploy(
      TattoRole.address,
      TattoCurrency.address
    );
    await TattoMarket.deployed();

    return { admin, user, TattoRole, TattoCurrency, TattoMarket };
  }

  it("buy lazyNFT", async function () {
    const { TattoMarket } = await loadFixture(deployMarket);
  });
  it("buy NFT", async function () {
    const { TattoMarket } = await loadFixture(deployMarket);
  });
  //수수료 체크
});
