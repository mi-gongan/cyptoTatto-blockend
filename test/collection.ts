import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";
import { lazyMintHash } from "./utils/hash";
import { arrayify, hashMessage } from "ethers/lib/utils";
import { BigNumber } from "ethers";

describe("collection", function () {
  //임의로 설정
  const ipfsHash = "23tave4qgq34gqgefrq3rf";
  const tokenId0 = BigNumber.from(1);

  async function deployCollection() {
    const [admin, user1, user2, back] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin.address);
    await TattoRole.deployed();

    await TattoRole.connect(admin).setBackAddress(back.address);

    const collectionToken = await ethers.getContractFactory("TattoCollection");
    const TattoCollection = await collectionToken.deploy(TattoRole.address);
    await TattoCollection.deployed();

    return { admin, user1, user2, back, TattoRole, TattoCollection };
  }

  it("본인에게 lazy mint", async function () {
    const { TattoCollection, user1, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user1.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(hash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user1.address,
        ipfsHash,
        back.address,
        hash,
        signature
      )
    )
      .to.emit(TattoCollection, "Mint")
      .withArgs(user1.address, tokenId0, ipfsHash);

    expect(await TattoCollection.ownerOf(tokenId0)).to.equal(user1.address);
  });
  it("상대에게 lazy mint", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user2.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(hash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user2.address,
        ipfsHash,
        back.address,
        hash,
        signature
      )
    )
      .to.emit(TattoCollection, "Mint")
      .withArgs(user2.address, tokenId0, ipfsHash);

    expect(await TattoCollection.ownerOf(tokenId0)).to.deep.equal(
      user2.address
    );
  });
  it("동일한 ipfs로 민팅", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user2.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(hash));

    await TattoCollection.connect(user1).lazyMint(
      user1.address,
      user2.address,
      ipfsHash,
      back.address,
      hash,
      signature
    );
    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user2.address,
        ipfsHash,
        back.address,
        hash,
        signature
      )
    )
      .to.revertedWithCustomError(
        TattoCollection,
        "TattoCollection_Same_IPFSHash"
      )
      .withArgs(ipfsHash);
  });
  it("hash not match", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const wrongHash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user1.address,
      ipfsHash
    );
    const rightHash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user2.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(rightHash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user2.address,
        ipfsHash,
        back.address,
        wrongHash,
        signature
      )
    )
      .to.revertedWithCustomError(
        TattoCollection,
        "TattoCollection_Hash_Does_Not_Match"
      )
      .withArgs(rightHash);
  });
  it("signer not match", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user2.address,
      ipfsHash
    );
    const wrongSignature = await user1.signMessage(arrayify(hash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user2.address,
        ipfsHash,
        back.address,
        hash,
        wrongSignature
      )
    )
      .to.revertedWithCustomError(
        TattoCollection,
        "TattoCollection_Signer_Address_Does_Not_Match"
      )
      .withArgs(user1.address);
  });
  it("transfer", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user1.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(hash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user1.address,
        ipfsHash,
        back.address,
        hash,
        signature
      )
    )
      .to.emit(TattoCollection, "Mint")
      .withArgs(user1.address, tokenId0, ipfsHash);

    expect(await TattoCollection.ownerOf(tokenId0)).to.equal(user1.address);

    //transfer후 owner바꼈는지 체크
    await expect(
      TattoCollection.connect(user1).transferFrom(
        user1.address,
        user2.address,
        tokenId0
      )
    )
      .to.emit(TattoCollection, "Transfer")
      .withArgs(user1.address, user2.address, tokenId0);

    expect(await TattoCollection.ownerOf(tokenId0)).to.equal(user2.address);
  });
  it("burn", async function () {
    const { TattoCollection, user1, user2, back } = await loadFixture(
      deployCollection
    );
    const hash = lazyMintHash(
      TattoCollection.address,
      user1.address,
      user1.address,
      ipfsHash
    );
    const signature = await back.signMessage(arrayify(hash));

    await expect(
      TattoCollection.connect(user1).lazyMint(
        user1.address,
        user1.address,
        ipfsHash,
        back.address,
        hash,
        signature
      )
    )
      .to.emit(TattoCollection, "Mint")
      .withArgs(user1.address, tokenId0, ipfsHash);

    expect(await TattoCollection.ownerOf(tokenId0)).to.equal(user1.address);

    await expect(TattoCollection.connect(user1).burn(tokenId0))
      .to.emit(TattoCollection, "Burn")
      .withArgs(tokenId0, ipfsHash);
  });
});
