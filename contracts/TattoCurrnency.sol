// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/ITattoRole.sol";

error TattoCurrency_Core_Should_Be_Contract();

error TattoCurrency_Currency_Not_Allowed();
error TattoCurrency_Address_Not_Allowed();

error TattoCurrency_Cannot_Deposit_To_Address_Zero();
error TattoCurrency_Cannot_Deposit_To_Contract();
error TattoCurrency_Cannot_Deposit_Zero_Amount();
error TattoCurrency_Not_Approved();

error TattoCurrency_Cannot_Withdraw_To_Address_Zero();
error TattoCurrency_Cannot_Withdraw_To_Contract();
error TattoCurrency_Cannot_Withdraw_Zero_Amount();
error TattoCurrency_No_Funds_To_Withdraw();

error TattoCurrency_Insufficient_Allowance(uint256 amount);
error TattoCurrency_Insufficient_Available_Funds(uint256 amount);

contract TattoCurrency {
  address internal tattoRole;

  uint256 private ETHTotal;

  mapping(address => uint256) accountBalance;

  event ETHTransfered(address indexed from, address indexed to, uint256 amount);

  event Withdrawn(address indexed from, address indexed to, uint256 amount);

  event Deposit(address indexed from, address indexed to, uint256 amount);

  modifier onlyAdmin() {
    if (!ITattoRole(tattoRole).isAdmin(msg.sender)) {
      revert TattoCurrency_Address_Not_Allowed();
    }
    _;
  }

  modifier marketOrAdmin() {
    if (
      !ITattoRole(tattoRole).isMarket(msg.sender) ||
      !ITattoRole(tattoRole).isAdmin(msg.sender)
    ) {
      revert TattoCurrency_Address_Not_Allowed();
    }
    _;
  }

  constructor(address _role) {
    tattoRole = _role;
  }

  receive() external payable {
    depositETHFor(msg.sender);
  }

  function depositETH() public payable {
    depositETHFor(msg.sender);
  }

  function depositETHFor(address account) public payable {
    if (msg.value == 0) {
      revert TattoCurrency_Cannot_Deposit_Zero_Amount();
    }
    if (account == address(0)) {
      revert TattoCurrency_Cannot_Deposit_To_Address_Zero();
    }
    if (account == address(this)) {
      revert TattoCurrency_Cannot_Deposit_To_Contract();
    }
    accountBalance[account] += msg.value;
    ETHTotal += msg.value;
    emit Deposit(msg.sender, account, msg.value);
  }

  function withdrawETH(uint256 amount) public {
    uint256 ETHBalance = accountBalance[msg.sender];
    if (amount == 0) {
      revert TattoCurrency_Cannot_Withdraw_Zero_Amount();
    }
    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }
    if (msg.sender == address(0)) {
      revert TattoCurrency_Cannot_Withdraw_To_Address_Zero();
    }
    if (msg.sender == address(this)) {
      revert TattoCurrency_Cannot_Withdraw_To_Contract();
    }

    accountBalance[msg.sender] -= amount;
    ETHTotal -= amount;

    payable(msg.sender).transfer(amount);

    emit Withdrawn(msg.sender, msg.sender, amount);
  }

  function reduceCurrencyFrom(address from, uint256 amount)
    external
    marketOrAdmin
  {
    uint256 ETHBalance = accountBalance[from];
    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }

    accountBalance[from] -= amount;
    ETHTotal -= amount;

    emit Withdrawn(from, address(this), amount);
  }

  function transferETHFrom(
    address from,
    address to,
    uint256 amount
  ) external marketOrAdmin {
    if (amount == 0) {
      revert TattoCurrency_Cannot_Withdraw_Zero_Amount();
    }
    if (to == address(0)) {
      revert TattoCurrency_Cannot_Withdraw_To_Address_Zero();
    }
    if (to == address(this)) {
      revert TattoCurrency_Cannot_Withdraw_To_Contract();
    }

    uint256 ETHBalance = accountBalance[from];
    if (ETHBalance < amount) {
      revert TattoCurrency_Insufficient_Available_Funds(ETHBalance);
    }
    accountBalance[from] -= amount;
    accountBalance[to] += amount;

    emit ETHTransfered(from, to, amount);
  }

  function adminWithdrawAvailableETH() external onlyAdmin {
    uint256 totalBalance = ETHTotal;
    uint256 realTotalBalance = address(this).balance;
    require(
      realTotalBalance > totalBalance,
      "TattoCurrency : Not enough balance"
    );

    uint256 availableBalance = realTotalBalance - totalBalance;

    payable(msg.sender).transfer(availableBalance);

    emit Withdrawn(address(this), msg.sender, availableBalance);
  }

  function balanceOf(address account) public view returns (uint256) {
    return accountBalance[account];
  }

  function availableETH() external view returns (uint256) {
    return address(this).balance - ETHTotal;
  }
}
