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

  address internal roleControlAddress;
  address currencyControlAddress;
  address backAddress;

  //수수료
  uint256 constant protocolPercent = 2;

  struct BuyerInfo {
    uint256 price;
    bytes32 payHash;
    bytes paySignature;
  }

  struct NFTInfo {
    address collectionAddress;
    address holderAddress;
    uint256 tokenId;
  }

  struct LazyNFTInfo {
    address collectionAddress;
    address creatorAddress;
    // 아래는 민팅을 하기위해 필요한 정보들
    string ipfsHash;
    bytes32 mintHash;
    bytes mintSignature;
  }

  struct BackValidateInfo {
    uint256 random;
    bytes32 backHash;
    bytes backSignature;
  }

  event BuyLazyNFT();

  event BuyNFT();

  constructor(
    address _role,
    address _currencyControlAddress,
    address _backAddress
  ) {
    roleControlAddress = _role;
    currencyControlAddress = _currencyControlAddress;
    backAddress = _backAddress;
  }

  function buyLazyNFT(
    // seller
    LazyNFTInfo memory lazyNFTInfo,
    // buyer
    BuyerInfo memory buyerInfo,
    // back
    BackValidateInfo memory backValidateInfo
  ) public payable {
    //verify
    _validateBackSignature(
      lazyNFTInfo.collectionAddress,
      lazyNFTInfo.creatorAddress,
      msg.sender,
      buyerInfo.price,
      backValidateInfo.random,
      backValidateInfo.backHash,
      backValidateInfo.backSignature
    );
    _validatePaySignature(
      msg.sender,
      buyerInfo.price,
      buyerInfo.payHash,
      buyerInfo.paySignature
    );

    //lazymint for buyer
    ITattoCollection(lazyNFTInfo.collectionAddress).lazyMint(
      lazyNFTInfo.creatorAddress,
      msg.sender,
      lazyNFTInfo.ipfsHash,
      lazyNFTInfo.mintHash,
      lazyNFTInfo.mintSignature
    );

    //transfer eth to seller
    uint256 buyerBalance = ITattoCurrency(currencyControlAddress).balanceOf(
      msg.sender
    );

    if (buyerInfo.price > buyerBalance) {
      revert TattoMarket_Price_Is_Larger_Than_BalanceOf();
    }

    ITattoCurrency(currencyControlAddress).reduceCurrencyFrom(
      msg.sender,
      (protocolPercent * buyerInfo.price) / 100
    );

    ITattoCurrency(currencyControlAddress).transferETHFrom(
      msg.sender,
      lazyNFTInfo.creatorAddress,
      ((100 - protocolPercent) * buyerInfo.price) / 100
    );

    emit BuyLazyNFT();
  }

  function buyNFT(
    //seller
    NFTInfo memory nftInfo,
    // buyer
    BuyerInfo memory buyerInfo,
    // back
    BackValidateInfo memory backValidateInfo
  ) public payable {
    //verify
    _validateBackSignature(
      nftInfo.collectionAddress,
      nftInfo.holderAddress,
      msg.sender,
      buyerInfo.price,
      backValidateInfo.random,
      backValidateInfo.backHash,
      backValidateInfo.backSignature
    );
    _validatePaySignature(
      msg.sender,
      buyerInfo.price,
      buyerInfo.payHash,
      buyerInfo.paySignature
    );

    // transfer nft to buyer
    IERC721(nftInfo.collectionAddress).transferFrom(
      nftInfo.holderAddress,
      msg.sender,
      nftInfo.tokenId
    );

    // transfer eth to seller
    uint256 buyerBalance = ITattoCurrency(currencyControlAddress).balanceOf(
      msg.sender
    );

    if (buyerInfo.price > buyerBalance) {
      revert TattoMarket_Price_Is_Larger_Than_BalanceOf();
    }

    ITattoCurrency(currencyControlAddress).reduceCurrencyFrom(
      msg.sender,
      (protocolPercent * buyerInfo.price) / 100
    );

    ITattoCurrency(currencyControlAddress).transferETHFrom(
      msg.sender,
      nftInfo.holderAddress,
      ((100 - protocolPercent) * buyerInfo.price) / 100
    );

    emit BuyNFT();
  }

  // 구매 정보에 대한 정보가 맞는지 buyer가 서명한건지 체크
  function _validatePaySignature(
    address buyer,
    uint256 price,
    bytes32 payHash,
    bytes memory paySignature
  ) internal pure {
    bytes32 calculatedHash = keccak256(
      abi.encodePacked(uint256(uint160(buyer)), uint256(price))
    );
    bytes32 calculatedOrigin = keccak256(
      abi.encodePacked(
        //ethereum signature prefix
        "\x19Ethereum Signed Message:\n32",
        //Orderer
        uint256(calculatedHash)
      )
    );
    address recoveredSigner = calculatedOrigin.recover(paySignature);

    if (calculatedHash != payHash) {
      revert TattoMarket_Hash_Does_Not_Match();
    }
    if (recoveredSigner != buyer) {
      revert TattoMarket_Signer_Address_Does_Not_Match();
    }
  }

  //같은 back signature를 이용해 중복거래를 방지하기 위해 거래에 대한 내용을 모두 포함시키고 난수값도 포함시킨다.
  function _validateBackSignature(
    address collectionAddress,
    address sellerAddress,
    address buyerAddress,
    uint256 price,
    uint256 random,
    bytes32 backHash,
    bytes memory backSignature
  ) internal view {
    bytes32 calculatedHash = keccak256(
      abi.encodePacked(
        uint256(uint160(collectionAddress)),
        uint256(uint160(sellerAddress)),
        uint256(uint160(buyerAddress)),
        uint256(price),
        uint256(random)
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
    address recoveredSigner = calculatedOrigin.recover(backSignature);

    if (calculatedHash != backHash) {
      revert TattoMarket_Hash_Does_Not_Match();
    }
    if (recoveredSigner != backAddress) {
      revert TattoMarket_Signer_Address_Does_Not_Match();
    }
  }

  function protocolFee() external pure returns (uint256) {
    return protocolPercent;
  }
}
