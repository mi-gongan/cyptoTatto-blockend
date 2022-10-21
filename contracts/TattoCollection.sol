// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./interface/ITattoCollection.sol";
import "./interface/ITattoRole.sol";

error TattoCollection_Hash_Does_Not_Match();
error TattoCollection_Signer_Address_Does_Not_Match();
error TattoCollection_Signer_Is_Not_Node();

contract TattoCollection is ERC721, ITattoCollection {
  using ECDSA for bytes32;

  uint256 internal lastTokenId;
  address internal tattoRole;

  mapping(bytes32 => bool) public mintHashHistory;
  mapping(uint256 => string) public tokenIPFSHash;
  mapping(uint256 => address) public tokenCreator;

  event Minted(
    address indexed creator,
    uint256 indexed tokenId,
    string tokenIPFSHash,
    bytes32 mintHash
  );

  event Burn(uint256 tokenId);

  constructor(address _role) ERC721("TattoCollection", "TATTO") {
    tattoRole = _role;
  }

  function burn(uint256 tokenId) public {
    _burn(tokenId);
    emit Burn(tokenId);
  }

  function lazyMint(
    address signerAddress,
    bytes memory mintSignature,
    bytes32 mintHash,
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash
  ) public override returns (uint256 tokenId) {
    require(!mintHashHistory[mintHash], "TattoCollection_Hash_Is_Duplicated");

    _validateMintSignature(
      signerAddress,
      mintSignature,
      mintHash,
      creatorAddress,
      receiverAddress,
      ipfsHash
    );

    unchecked {
      // Number of tokens cannot overflow 256 bits.
      tokenId = ++lastTokenId;
    }
    _mint(receiverAddress, tokenId);
    _setTokenIPFSHash(tokenId, ipfsHash);

    mintHashHistory[mintHash] = true;

    emit Minted(receiverAddress, tokenId, ipfsHash, mintHash);
  }

  function orderMint(
    bytes32 mintHash,
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash
  ) public override returns (uint256 tokenId) {
    require(!mintHashHistory[mintHash], "TattoCollection_Hash_Is_Duplicated");

    unchecked {
      // Number of tokens cannot overflow 256 bits.
      tokenId = ++lastTokenId;
    }
    _mint(receiverAddress, tokenId);
    _setTokenIPFSHash(tokenId, ipfsHash);
    _setTokenCreator(tokenId, creatorAddress);

    mintHashHistory[mintHash] = true;

    emit Minted(receiverAddress, tokenId, ipfsHash, mintHash);
  }

  function getIPFSHashById(uint256 tokenId)
    public
    view
    returns (string memory IPFSHash)
  {
    require(
      _exists(tokenId),
      "TattoCollection_Hash_URIQuery_For_Non_Existent_Token"
    );
    IPFSHash = tokenIPFSHash[tokenId];
  }

  function _setTokenIPFSHash(uint256 tokenId, string memory ipfsHash) internal {
    tokenIPFSHash[tokenId] = ipfsHash;
  }

  function _setTokenCreator(uint256 tokenId, address creator) internal {
    tokenCreator[tokenId] = creator;
  }

  function _validateMintSignature(
    address signerAddress,
    bytes memory mintSignature,
    bytes32 mintHash,
    address creatorAddress,
    address receiverAddress,
    string memory ipfsHash
  ) internal view {
    if (!ITattoRole(tattoRole).isBack(signerAddress)) {
      revert TattoCollection_Signer_Is_Not_Node();
    }

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
      revert TattoCollection_Hash_Does_Not_Match();
    }

    if (recoveredSigner != signerAddress) {
      revert TattoCollection_Signer_Address_Does_Not_Match();
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
