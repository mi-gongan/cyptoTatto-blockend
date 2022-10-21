import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";

describe("currency", function () {
  async function deployCurrency() {
    const [admin, user] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin);
    await TattoRole.deployed();

    const currencyToken = await ethers.getContractFactory("TattoCurrency");
    const TattoCurrency = await currencyToken.deploy(TattoRole.address);
    await TattoCurrency.deployed();

    return { admin, user, TattoRole, TattoCurrency };
  }

  it("deposit", async function () {
    const { TattoCurrency } = await loadFixture(deployCurrency);
  });
  it("withdraw", async function () {
    const { TattoCurrency } = await loadFixture(deployCurrency);
  });
});
