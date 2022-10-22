// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/ITattoRole.sol";
import "hardhat/console.sol";

error TattoCurrency_Only_Admin();
error TattoCurrency_Only_Market();
error TattoCurrency_Insufficient_Available_Funds(uint256 amount);

contract TattoCurrency {
  address internal tattoRole;

  mapping(address => uint256) accountBalance;

  event ETHTransfer(address from, address to, uint256 amount);

  event Withdraw(address from, address to, uint256 amount);

  event Deposit(address from, address to, uint256 amount);

  modifier onlyAdmin() {
    if (!ITattoRole(tattoRole).isAdmin(msg.sender)) {
      revert TattoCurrency_Only_Admin();
    }
    _;
  }

  //market에서만 가능하도록
  modifier onlyMarket() {
    if (!ITattoRole(tattoRole).isMarket(msg.sender)) {
      revert TattoCurrency_Only_Market();
    }
    _;
  }

  constructor(address _role) {
    tattoRole = _role;
  }

  receive() external payable {
    depositETH();
  }

  function depositETH() public payable {
    accountBalance[msg.sender] += msg.value;
    emit Deposit(msg.sender, address(this), msg.value);
  }

  function withdrawETH(uint256 amount) public {
    uint256 ETHBalance = accountBalance[msg.sender];

    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }

    accountBalance[msg.sender] -= amount;

    payable(msg.sender).transfer(amount);

    emit Withdraw(address(this), msg.sender, amount);
  }

  //protocol fee만큼 감소시키는 함수
  function reduceCurrencyFrom(address from, uint256 amount)
    external
    onlyMarket
  {
    uint256 ETHBalance = accountBalance[from];
    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }

    address adminAddress = ITattoRole(tattoRole).getAdminAddress();

    accountBalance[from] -= amount;
    accountBalance[adminAddress] += amount;

    emit Withdraw(from, address(this), amount);
  }

  function transferETHFrom(
    address from,
    address to,
    uint256 amount
  ) external onlyMarket {
    uint256 ETHBalance = accountBalance[from];
    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }
    accountBalance[from] -= amount;
    accountBalance[to] += amount;

    emit ETHTransfer(from, to, amount);
  }

  function balanceOf(address account) public view returns (uint256) {
    return accountBalance[account];
  }
}
