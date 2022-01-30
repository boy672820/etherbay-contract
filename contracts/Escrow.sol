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

  address private _owner;

  mapping(uint256 => Trade) public trades;

  IProductOwnership public product;
  uint256 public tradeCounter;

  constructor(address _productAddress) {
    _owner = msg.sender;
    tradeCounter = 0;
    setProductOwnership(_productAddress);
  }

  modifier onlyOwner() {
    require(_owner == msg.sender, 'Caller is not the owner');
    _;
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

  function executeTrade(uint256 _tradeId) external payable {
    require(trades[_tradeId].status == 'open', 'Trade is not open');
    require(trades[_tradeId].amount == msg.value, 'Trade amount does not match.');

    payable(msg.sender).transfer(msg.value);
    // withdraw
  }

  function setProductOwnership(address _productAddress) public onlyOwner {
    product = IProductOwnership(_productAddress);
  }

  function changeOwner(address _newOwner) public onlyOwner {
    _owner = _newOwner;
  }
}
