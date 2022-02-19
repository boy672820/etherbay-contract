//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract EtherbayProduct is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;

  constructor() ERC721('Etherbay Product', 'EBP') {}

  function mint(address recipient, string calldata tokenURI) public onlyOwner {
    _tokenIds.increment();

    uint256 newTokenId = _tokenIds.current();
    _mint(recipient, newTokenId);
    _setTokenURI(newTokenId, tokenURI);
  }
}
