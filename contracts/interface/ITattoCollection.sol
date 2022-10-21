// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITattoCollection {
    function lazyMint(
        address signerAddress,
        bytes memory mintSignature,
        bytes32 mintHash,
        address creatorAddress,
        address receiverAddress,
        string memory ipfsHash
    ) external returns (uint256 tokenId);

    function orderMint(
        bytes32 mintHash,
        address creatorAddress,
        address receiverAddress,
        string memory ipfsHash
    ) external returns (uint256 tokenId);
}
