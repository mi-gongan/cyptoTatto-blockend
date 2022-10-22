// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TattoRole {
  address internal adminAddress;
  address internal marketAddress;

  constructor(address _admin) {
    adminAddress = _admin;
  }

  modifier onlyAdmin() {
    require(msg.sender != adminAddress, "TattoRole_Msg_Sender_Is_Not_Admin");
    _;
  }

  function isAmin(address _admin) public view returns (bool) {
    return (adminAddress == _admin);
  }

  function isMarket(address _market) public view returns (bool) {
    return (marketAddress == _market);
  }

  function setAdminAddress(address _admin) public onlyAdmin {
    adminAddress = _admin;
  }

  function setMarketAddress(address _market) public onlyAdmin {
    marketAddress = _market;
  }
}
