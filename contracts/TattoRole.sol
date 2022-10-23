// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TattoRole {
  address internal adminAddress;
  address internal marketAddress;
  address internal backAddress;

  constructor(address _admin) {
    adminAddress = _admin;
  }

  modifier onlyAdmin() {
    require(msg.sender == adminAddress, "TattoRole_Msg_Sender_Is_Not_Admin");
    _;
  }

  function isAmin(address _admin) public view returns (bool) {
    return (adminAddress == _admin);
  }

  function isMarket(address _market) public view returns (bool) {
    return (marketAddress == _market);
  }

  function isBack(address _back) public view returns (bool) {
    return (backAddress == _back);
  }

  function getAdminAddress() public view returns (address) {
    return adminAddress;
  }

  function getMarketAddress() public view returns (address) {
    return marketAddress;
  }

  function getBackAddress() public view returns (address) {
    return backAddress;
  }

  function setMarketAddress(address _market) public onlyAdmin {
    marketAddress = _market;
  }

  function setBackAddress(address _back) public onlyAdmin {
    backAddress = _back;
  }
}
