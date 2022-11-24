import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";
import { lazyMintHash, payHash, tradeHash } from "./utils/hash";
import { arrayify } from "ethers/lib/utils";

describe("market", function () {
  const ipfsHash = "awergq234gfq34c3q4gfqerf";
  const price = ethers.utils.parseEther("0.5");
  const protocolFee = ethers.utils.parseEther(`0.01`);
  const sellerFee = ethers.utils.parseEther(`0.49`);
  const salt = Math.floor(Math.random() * 100);
  async function deployMarket() {
    const [admin, seller, buyer, back] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin.address);
    await TattoRole.deployed();

    await TattoRole.connect(admin).setBackAddress(back.address);

    const currencyToken = await ethers.getContractFactory("TattoCurrency");
    const TattoCurrency = await currencyToken.deploy(TattoRole.address);
    await TattoCurrency.deployed();

    const marketyToken = await ethers.getContractFactory("TattoMarket");
    const TattoMarket = await marketyToken.deploy(
      TattoRole.address,
      TattoCurrency.address
    );
    await TattoMarket.deployed();

    await TattoRole.connect(admin).setMarketAddress(TattoMarket.address);

    const collectionToken = await ethers.getContractFactory("TattoCollection");
    const TattoCollection = await collectionToken.deploy(TattoRole.address);
    await TattoCollection.deployed();

    return {
      admin,
      seller,
      buyer,
      back,
      TattoRole,
      TattoCurrency,
      TattoMarket,
      TattoCollection,
    };
  }

  it("buy lazyNFT", async function () {
    const {
      seller,
      buyer,
      back,
      TattoMarket,
      TattoCollection,
      TattoCurrency,
      admin,
    } = await loadFixture(deployMarket);
    const mintHash = lazyMintHash(
      TattoCollection.address,
      seller.address,
      buyer.address,
      ipfsHash
    );
    const mintSignature = await back.signMessage(arrayify(mintHash));

    await TattoCurrency.connect(buyer).depositETH({ value: price });
    const payHashValue = payHash(buyer.address, price);
    const paySignature = await buyer.signMessage(arrayify(payHashValue));

    const randomHere = salt;

    const tradeHashValue = tradeHash(
      TattoCollection.address,
      seller.address,
      buyer.address,
      price,
      randomHere
    );
    const tradeSignature = await back.signMessage(arrayify(tradeHashValue));

    await expect(
      TattoMarket.connect(buyer).buyLazyNFT(
        [
          TattoCollection.address,
          seller.address,
          ipfsHash,
          mintHash,
          mintSignature,
        ],
        [price, payHashValue, paySignature],
        [randomHere, back.address, tradeHashValue, tradeSignature]
      )
    ).to.emit(TattoMarket, "BuyLazyNFT");

    expect(await TattoCollection.ownerOf(1)).to.equal(buyer.address);
    expect(await TattoCurrency.balanceOf(seller.address)).to.equal(sellerFee);
    expect(await TattoCurrency.balanceOf(admin.address)).to.equal(protocolFee);
  });
  it("buy NFT", async function () {
    const {
      seller,
      buyer,
      back,
      TattoMarket,
      TattoCollection,
      TattoCurrency,
      admin,
    } = await loadFixture(deployMarket);

    const mintHash = lazyMintHash(
      TattoCollection.address,
      seller.address,
      seller.address,
      ipfsHash
    );
    const mintSignature = await back.signMessage(arrayify(mintHash));

    await TattoCollection.connect(seller).lazyMint(
      seller.address,
      seller.address,
      ipfsHash,
      back.address,
      mintHash,
      mintSignature
    );

    //approve 하는 행위가 꼭 필요
    await TattoCollection.connect(seller).setApprovalForAll(
      TattoMarket.address,
      true
    );

    await TattoCurrency.connect(buyer).depositETH({ value: price });
    const payHashValue = payHash(buyer.address, price);
    const paySignature = await buyer.signMessage(arrayify(payHashValue));

    const randomHere = salt;

    const tradeHashValue = tradeHash(
      TattoCollection.address,
      seller.address,
      buyer.address,
      price,
      randomHere
    );
    const tradeSignature = await back.signMessage(arrayify(tradeHashValue));

    await expect(
      TattoMarket.connect(buyer).buyNFT(
        [TattoCollection.address, seller.address, 1],
        [price, payHashValue, paySignature],
        [randomHere, back.address, tradeHashValue, tradeSignature]
      )
    ).to.emit(TattoMarket, "BuyNFT");

    expect(await TattoCollection.ownerOf(1)).to.equal(buyer.address);
    expect(await TattoCurrency.balanceOf(seller.address)).to.equal(sellerFee);
    expect(await TattoCurrency.balanceOf(admin.address)).to.equal(protocolFee);
  });
});
