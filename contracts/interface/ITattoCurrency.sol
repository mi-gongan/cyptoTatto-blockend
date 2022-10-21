// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITattoCurrency {
  function depositETH() external payable;

  function depositETHFor(address account) external payable;

  function withdrawETH(uint256 amount) external;

  function reduceCurrencyFrom(address from, uint256 amount) external;

  function transferETHFrom(
    address from,
    address to,
    uint256 amount
  ) external;

  function adminWithdrawAvailableETH() external;

  function balanceOf(address account) external view returns (uint256);

  function availableETH() external view returns (uint256);
}
