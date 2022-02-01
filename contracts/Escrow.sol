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
    bytes32 status; // open, executed, confirmed, cancelled
  }

  address private _owner;

  IProductOwnership public product;

  mapping(uint256 => Trade) public trades;
  mapping(uint256 => address) public executedTradeToSpender;
  uint256 public tradeCounter;

  // ----------------------------------------------------------------------

  modifier onlyOwner() {
    require(_owner == msg.sender, 'Caller is not the owner');
    _;
  }

  // ----------------------------------------------------------------------

  constructor(address _productAddress) {
    _owner = msg.sender;
    tradeCounter = 0;
    setProductOwnership(_productAddress);
  }

  /**
   * @dev 거래 생성
   */
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

  /**
   * @dev 거래 구매
   */
  function executeTrade(uint256 _tradeId) external payable {
    require(trades[_tradeId].status == 'open', 'Trade is not open');
    require(
      trades[_tradeId].amount == msg.value,
      'Trade amount does not match.'
    );

    executedTradeToSpender[_tradeId] = msg.sender;
    trades[_tradeId].status = 'executed';

    emit TradeStatusChange(_tradeId, 'executed');
  }

  /**
   * @dev 거래 확인
   */
  function confirmTrade(uint256 _tradeId) external {
    require(trades[_tradeId].status == 'executed', 'Trade is not excuted');
    require(msg.sender == trades[_tradeId].poster, 'Caller is not the poster');

    product.transferFrom(
      address(this),
      executedTradeToSpender[_tradeId],
      trades[_tradeId].tokenId
    );

    payable(trades[_tradeId].poster).transfer(trades[_tradeId].amount);

    trades[_tradeId].status = 'confirmed';

    emit TradeStatusChange(_tradeId, 'confirmed');
  }

  /**
   * @dev 거래 등록 취소
   */
  function cancelTrade(uint256 _tradeId) external {
    require(trades[_tradeId].status == 'open', 'Trade is not open');
    require(msg.sender == trades[_tradeId].poster, 'Caller is not the poster');

    product.transferFrom(address(this), msg.sender, trades[_tradeId].tokenId);

    trades[_tradeId].status = 'cancelled';

    emit TradeStatusChange(_tradeId, 'cancelled');
  }

  // ----------------------------------------------------------------------

  /**
   * @dev ProductOwnership 컨트랙트 주소 변경
   */
  function setProductOwnership(address _productAddress) public onlyOwner {
    product = IProductOwnership(_productAddress);
  }

  /**
   * @dev 컨트랙트 소유자 변경
   */
  function changeOwner(address _newOwner) external onlyOwner {
    _owner = _newOwner;
  }
}
