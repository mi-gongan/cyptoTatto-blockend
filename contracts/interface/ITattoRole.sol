// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITattoRole {
  function isAdmin(address _admin) external view returns (bool);

  function isBack(address _back) external view returns (bool);

  function isMarket(address _market) external view returns (bool);
}
