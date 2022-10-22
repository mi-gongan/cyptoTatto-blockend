// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITattoCollection {
  function lazyMint(
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash,
    address backAddress,
    bytes32 mintHash,
    bytes memory mintSignature
  ) external returns (uint256 tokenId);
}
