import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";

// describe("market", function () {
//   async function deployMarket() {
//     const [admin, seller, buyer] = await ethers.getSigners();

//     const roleToken = await ethers.getContractFactory("TattoRole");
//     const TattoRole = await roleToken.deploy(admin.address);
//     await TattoRole.deployed();

//     const currencyToken = await ethers.getContractFactory("TattoCurrency");
//     const TattoCurrency = await currencyToken.deploy(TattoRole.address);
//     await TattoCurrency.deployed();

//     const marketyToken = await ethers.getContractFactory("TattoMarket");
//     const TattoMarket = await marketyToken.deploy(TattoCurrency.address);
//     await TattoMarket.deployed();

//     const collectionToken = await ethers.getContractFactory("TattoCollection");
//     const TattoCollection = await collectionToken.deploy(TattoRole.address);
//     await TattoCollection.deployed();

//     return {
//       admin,
//       seller,
//       buyer,
//       TattoRole,
//       TattoCurrency,
//       TattoMarket,
//       TattoCollection,
//     };
//   }

//   it("buy lazyNFT", async function () {
//     const { TattoMarket } = await loadFixture(deployMarket);
//   });
//   it("buy NFT", async function () {
//     const { TattoMarket } = await loadFixture(deployMarket);
//   });
//   //수수료 체크
// });
