import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import "@nomicfoundation/hardhat-chai-matchers";

describe("currency", function () {
  const ethValue = ethers.utils.parseEther("0.5");

  async function deployCurrency() {
    const [admin, user1, user2, market] = await ethers.getSigners();

    const roleToken = await ethers.getContractFactory("TattoRole");
    const TattoRole = await roleToken.deploy(admin.address);
    await TattoRole.deployed();

    TattoRole.connect(admin).setMarketAddress(market.address);

    const currencyToken = await ethers.getContractFactory("TattoCurrency");
    const TattoCurrency = await currencyToken.deploy(TattoRole.address);
    await TattoCurrency.deployed();

    return { admin, user1, user2, market, TattoRole, TattoCurrency };
  }

  it("deposit", async function () {
    const { TattoCurrency, user1 } = await loadFixture(deployCurrency);
    await expect(TattoCurrency.connect(user1).depositETH({ value: ethValue }))
      .to.emit(TattoCurrency, "Deposit")
      .withArgs(user1.address, TattoCurrency.address, ethValue);
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(ethValue);
  });
  it("withdraw", async function () {
    const { TattoCurrency, user1 } = await loadFixture(deployCurrency);
    await TattoCurrency.connect(user1).depositETH({ value: ethValue });
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(ethValue);
    await expect(TattoCurrency.connect(user1).withdrawETH(ethValue))
      .to.emit(TattoCurrency, "Withdraw")
      .withArgs(TattoCurrency.address, user1.address, ethValue);
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(0);
  });
  it("withdraw two", async function () {
    const { TattoCurrency, user1 } = await loadFixture(deployCurrency);
    await TattoCurrency.connect(user1).depositETH({ value: ethValue });
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(ethValue);
    await TattoCurrency.connect(user1).withdrawETH(ethValue);
    await expect(TattoCurrency.connect(user1).withdrawETH(ethValue))
      .to.revertedWithCustomError(
        TattoCurrency,
        "TattoCurrency_Insufficient_Available_Funds"
      )
      .withArgs(0);
  });
  it("transfer", async function () {
    const { TattoCurrency, user1, user2, market } = await loadFixture(
      deployCurrency
    );
    await TattoCurrency.connect(user1).depositETH({ value: ethValue });
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(ethValue);
    await expect(
      TattoCurrency.connect(market).transferETHFrom(
        user1.address,
        user2.address,
        ethValue
      )
    )
      .to.emit(TattoCurrency, "ETHTransfer")
      .withArgs(user1.address, user2.address, ethValue);
    expect(
      await TattoCurrency.connect(user1).balanceOf(user1.address)
    ).to.equal(0);
    expect(
      await TattoCurrency.connect(user2).balanceOf(user2.address)
    ).to.equal(ethValue);
  });
});
