// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./interface/ITattoCollection.sol";
import "./interface/ITattoRole.sol";
import "hardhat/console.sol";

error TattoCollection_Same_IPFSHash(string ipfsHash);
error TattoCollection_Hash_Does_Not_Match(bytes32 calculatedHash);
error TattoCollection_Signer_Address_Does_Not_Match(address calculatedSigner);

contract TattoCollection is ERC721, ITattoCollection {
  using ECDSA for bytes32;

  uint256 internal lastTokenId;
  address internal tattoRole;

  mapping(uint256 => string) public tokenIPFSHash;
  // 0이면 사용하지 않음, 1이면 사용한것
  mapping(string => uint256) internal ipfsHashUsed;

  event Mint(address receiverAddress, uint256 tokenId, string tokenIPFSHash);

  event Burn(uint256 tokenId, string tokenIPFSHash);

  constructor(address _role) ERC721("TattoCollection", "TATTO") {
    tattoRole = _role;
  }

  function lazyMint(
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash,
    bytes32 mintHash,
    bytes memory mintSignature
  ) public override returns (uint256 tokenId) {
    if (ipfsHashUsed[ipfsHash] == 1) {
      revert TattoCollection_Same_IPFSHash(ipfsHash);
    }
    _validateLazyMintSignature(
      creatorAddress,
      receiverAddress,
      ipfsHash,
      mintHash,
      mintSignature
    );

    unchecked {
      // Number of tokens cannot overflow 256 bits.
      tokenId = ++lastTokenId;
    }

    _mint(receiverAddress, tokenId);
    _setTokenIPFSHash(tokenId, ipfsHash);

    ipfsHashUsed[ipfsHash] = 1;

    emit Mint(receiverAddress, tokenId, ipfsHash);
  }

  function burn(uint256 tokenId) public {
    string memory ipfsHash = getIPFSHashById(tokenId);
    _burn(tokenId);
    emit Burn(tokenId, ipfsHash);
  }

  function getIPFSHashById(uint256 tokenId)
    public
    view
    returns (string memory ipfsHash)
  {
    require(
      _exists(tokenId),
      "TattoCollection_Hash_URIQuery_For_Non_Existent_Token"
    );
    ipfsHash = tokenIPFSHash[tokenId];
  }

  function _setTokenIPFSHash(uint256 tokenId, string memory ipfsHash) internal {
    tokenIPFSHash[tokenId] = ipfsHash;
  }

  function _validateLazyMintSignature(
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash,
    bytes32 mintHash,
    bytes memory mintSignature
  ) internal view {
    bytes32 calculatedHash = keccak256(
      abi.encodePacked(
        uint256(uint160(address(this))),
        uint256(uint160(creatorAddress)),
        uint256(uint160(receiverAddress)),
        ipfsHash
      )
    );
    bytes32 calculatedSignature = keccak256(
      abi.encodePacked(
        //ethereum signature prefix
        "\x19Ethereum Signed Message:\n32",
        uint256(calculatedHash)
      )
    );
    address recoveredSigner = calculatedSignature.recover(mintSignature);

    if (calculatedHash != mintHash) {
      revert TattoCollection_Hash_Does_Not_Match(calculatedHash);
    }

    if (recoveredSigner != creatorAddress) {
      revert TattoCollection_Signer_Address_Does_Not_Match(recoveredSigner);
    }
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override
    returns (bool)
  {
    if (interfaceId == type(ITattoCollection).interfaceId) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  }
}
