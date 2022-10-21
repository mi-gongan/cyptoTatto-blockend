// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./interface/ITattoCollection.sol";
import "./interface/ITattoRole.sol";
import "./interface/ITattoCurrency.sol";

error TattoMarket_Is_Not_Node();
error TattoMarket_There_Is_Already_Record();
error TattoMarket_Price_Is_Larger_Than_BalanceOf();
error TattoMarket_Signer_Address_Does_Not_Match();
error TattoMarket_Hash_Does_Not_Match();

contract TattoMarket {
  using ECDSA for bytes32;

  //수수료
  uint256 constant protocolPercent = 2;

  mapping(bytes32 => bool) public orderRecord;

  address internal tattoRole;
  address internal currencyControlAddress;

  struct ValidateInfo {
    bytes32 hashValue;
    bytes signature;
  }

  struct NFTInfo {
    address account;
    address collectionAddress;
    uint256 tokenId;
  }

  struct LazyNFTInfo {
    address collectionAddress;
    address creatorAddress;
    string ipfsHash;
    bytes32 hashValue;
  }

  event BuyLazyNFT(uint256 tokenId);

  event BuyNFT();

  constructor(address _role, address _currencyControlAddress) {
    tattoRole = _role;
    currencyControlAddress = _currencyControlAddress;
  }

  //msg.sender이 구매자
  function buyLazyNFT(
    address singerAddress,
    uint256 price,
    //nft Info
    LazyNFTInfo memory lazyNFTInfo,
    // valdate info
    ValidateInfo memory buyLazyValidate
  ) public payable {
    if (orderRecord[buyLazyValidate.hashValue]) {
      revert TattoMarket_There_Is_Already_Record();
    }

    if (!ITattoRole(tattoRole).isBack(singerAddress)) {
      revert TattoMarket_Is_Not_Node();
    }

    //verify
    _validateBuyLazySignature(
      singerAddress,
      msg.sender,
      price,
      lazyNFTInfo,
      buyLazyValidate
    );

    //lazymint for buyer
    uint256 mintedTokenId = ITattoCollection(lazyNFTInfo.collectionAddress)
      .orderMint(
        lazyNFTInfo.hashValue,
        lazyNFTInfo.creatorAddress,
        msg.sender,
        lazyNFTInfo.ipfsHash
      );

    //transfer eth to seller
    uint256 buyerBalance = ITattoCurrency(currencyControlAddress).balanceOf(
      msg.sender
    );

    if (price > buyerBalance) {
      revert TattoMarket_Price_Is_Larger_Than_BalanceOf();
    }

    ITattoCurrency(currencyControlAddress).reduceCurrencyFrom(
      msg.sender,
      (protocolPercent * price) / 100
    );

    ITattoCurrency(currencyControlAddress).transferETHFrom(
      msg.sender,
      lazyNFTInfo.creatorAddress,
      ((100 - protocolPercent) * price) / 100
    );

    //hash keep
    orderRecord[buyLazyValidate.hashValue] = true;

    emit BuyLazyNFT(mintedTokenId);
  }

  //msg.sender이 구매자
  function buyNFT(
    address singerAddress,
    uint256 price,
    NFTInfo memory nftInfo,
    ValidateInfo memory buyValidate
  ) public payable {
    if (orderRecord[buyValidate.hashValue]) {
      revert TattoMarket_There_Is_Already_Record();
    }

    if (!ITattoRole(tattoRole).isBack(singerAddress)) {
      revert TattoMarket_Is_Not_Node();
    }

    //verify
    _validateBuySignature(
      singerAddress,
      msg.sender,
      price,
      nftInfo,
      buyValidate
    );

    // transfer nft to buyer
    IERC721(nftInfo.collectionAddress).transferFrom(
      nftInfo.account,
      msg.sender,
      nftInfo.tokenId
    );

    uint256 buyerBalance = ITattoCurrency(currencyControlAddress).balanceOf(
      msg.sender
    );

    // transfer eth to seller
    if (price > buyerBalance) {
      revert TattoMarket_Price_Is_Larger_Than_BalanceOf();
    }

    ITattoCurrency(currencyControlAddress).reduceCurrencyFrom(
      msg.sender,
      (protocolPercent * price) / 100
    );

    ITattoCurrency(currencyControlAddress).transferETHFrom(
      msg.sender,
      nftInfo.account,
      ((100 - protocolPercent) * price) / 100
    );

    //hash keep
    orderRecord[buyValidate.hashValue] = true;

    emit BuyNFT();
  }

  function _validateBuyLazySignature(
    address singerAddress,
    address buyer,
    uint256 price,
    LazyNFTInfo memory nftInfo,
    ValidateInfo memory buyLazyValidate
  ) internal pure {
    bytes32 calculatedHash = keccak256(
      abi.encodePacked(
        //buyer
        uint256(uint160(buyer)),
        price,
        uint256(uint160(nftInfo.collectionAddress)),
        uint256(uint160(nftInfo.creatorAddress)),
        nftInfo.ipfsHash
      )
    );
    bytes32 calculatedOrigin = keccak256(
      abi.encodePacked(
        //ethereum signature prefix
        "\x19Ethereum Signed Message:\n32",
        //Orderer
        uint256(calculatedHash)
      )
    );
    address recoveredSigner = calculatedOrigin.recover(
      buyLazyValidate.signature
    );

    if (calculatedHash != buyLazyValidate.hashValue) {
      revert TattoMarket_Hash_Does_Not_Match();
    }
    if (recoveredSigner != singerAddress) {
      revert TattoMarket_Signer_Address_Does_Not_Match();
    }
  }

  function _validateBuySignature(
    address singerAddress,
    address buyer,
    uint256 price,
    NFTInfo memory nftInfo,
    ValidateInfo memory buyValidate
  ) internal pure {
    bytes32 calculatedHash = keccak256(
      abi.encodePacked(
        //buyer
        uint256(uint160(buyer)),
        price,
        // NFT
        uint256(uint160(nftInfo.account)),
        uint256(uint160(nftInfo.collectionAddress)),
        nftInfo.tokenId
      )
    );
    bytes32 calculatedOrigin = keccak256(
      abi.encodePacked(
        //ethereum signature prefix
        "\x19Ethereum Signed Message:\n32",
        //Orderer
        uint256(calculatedHash)
      )
    );
    address recoveredSigner = calculatedOrigin.recover(buyValidate.signature);

    if (calculatedHash != buyValidate.hashValue) {
      revert TattoMarket_Hash_Does_Not_Match();
    }
    if (recoveredSigner != singerAddress) {
      revert TattoMarket_Signer_Address_Does_Not_Match();
    }
  }

  function protocolFee() external pure returns (uint256) {
    return protocolPercent;
  }
}
