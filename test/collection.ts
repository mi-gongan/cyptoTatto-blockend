import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";

describe("collection", function () {
  async function deployCollection() {
    const [admin, user] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin);
    await TattoRole.deployed();

    const collectionToken = await ethers.getContractFactory("TattoCollection");
    const TattoCollection = await collectionToken.deploy(TattoRole.address);
    await TattoCollection.deployed();

    return { admin, user, TattoRole, TattoCollection };
  }

  it("lazy mint", async function () {
    const { TattoCollection } = await loadFixture(deployCollection);
  });
  it("order mint", async function () {
    const { TattoCollection } = await loadFixture(deployCollection);
  });
  it("transfer", async function () {
    const { TattoCollection } = await loadFixture(deployCollection);
  });
  it("burn", async function () {
    const { TattoCollection } = await loadFixture(deployCollection);
  });
});
