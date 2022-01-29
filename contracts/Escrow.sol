//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IProductOwnership.sol';

contract Escrow {
  struct Trade {
    address poster;
    uint256 item;
    uint256 price;
    bytes32 status; // Open, Executed, Cancelled
  }

  mapping(uint256 => Trade) public trades;

  IProductOwnership itemToken;
  uint256 tradeCounter;

  constructor(address _itemTokenAddress) {
    itemToken = IProductOwnership(_itemTokenAddress);
    tradeCounter = 0;
  }
}
