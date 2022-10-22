// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITattoRole {
  function isAdmin(address _admin) external returns (bool);

  function isBack(address _back) external returns (bool);

  function isMarket(address _market) external returns (bool);

  function getAdminAddress() external returns (address);

  function getMarketAddress() external returns (address);

  function getBackAddress() external returns (address);
}
