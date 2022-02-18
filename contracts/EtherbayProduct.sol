//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract EtherbayProduct is ERC721 {
  constructor() ERC721('Etherbay Product', 'EBP') {}
}
