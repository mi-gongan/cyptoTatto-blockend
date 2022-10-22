import { BigNumber } from "ethers";
import { ethers } from "hardhat";

export function lazyMintHash(
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

export function payHash(buyerAddress: string, price: BigNumber) {
  const hash = ethers.utils.solidityKeccak256(
    ["uint256", "uint256"],
    [BigInt(buyerAddress), price]
  );
  return hash;
}
