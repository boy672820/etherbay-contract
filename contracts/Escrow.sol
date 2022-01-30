//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IProductOwnership.sol';
import 'hardhat/console.sol';

contract Escrow {
  event TradeStatusChange(uint256 tradeId, string status);
  
  struct Trade {
    address poster;
    uint256 tokenId;
    uint256 amount;
    bytes32 status; // open, executed, cancelled
  }

  mapping(uint256 => Trade) public trades;

  IProductOwnership product;
  uint256 tradeCounter;

  constructor(address _productAddress) {
    product = IProductOwnership(_productAddress);
    tradeCounter = 0;
  }

  function openTrade(uint256 _tokenId, uint256 _amount) external {
    product.transferFrom(msg.sender, address(this), _tokenId);

    uint256 tradeId = tradeCounter;

    trades[tradeId] = Trade({
      poster: msg.sender,
      tokenId: _tokenId,
      amount: _amount,
      status: 'open'
    });

    tradeCounter++;

    emit TradeStatusChange(tradeId, 'open');
  }
}
