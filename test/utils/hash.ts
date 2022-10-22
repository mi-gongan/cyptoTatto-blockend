import { BigNumber } from "ethers";
import { ethers } from "hardhat";

function lazyMintHash(
  collectionAddress: string,
  creatorAddress: string,
  receiverAddress: string,
  ipfsHash: string
) {
  const hash = ethers.utils.solidityKeccak256(
    ["uint256", "uint256", "uint256", "string"],
    [
      BigInt(collectionAddress),
      BigInt(creatorAddress),
      BigInt(receiverAddress),
      ipfsHash,
    ]
  );
  return hash;
}

function payHash(buyerAddress: string, price: BigNumber) {
  const hash = ethers.utils.solidityKeccak256(
    ["uint256", "uint256"],
    [BigInt(buyerAddress), price]
  );
  return hash;
}
