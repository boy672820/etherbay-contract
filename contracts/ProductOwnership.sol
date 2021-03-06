//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ProductFactory.sol';
import './IProductOwnership.sol';

contract ProductOwnership is ProductFactory, IProductOwnership {
  mapping(uint256 => address) private _approvals;

  /**
   * @dev 토큰 소유량 가져오기
   */
  function balanceOf(address _owner)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return ownerProductCount[_owner];
  }

  /**
   * @dev 토큰 소유자 가져오기
   */
  function ownerOf(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    return productToOwner[_tokenId];
  }

  /**
   * @dev 소유자 또는 승인 여부에 따른 토큰 전송
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) external virtual override {
    require(
      _isApprovedOrOwner(msg.sender, _tokenId),
      'Transfer caller is not owner nor approved'
    );

    _transfer(_from, _to, _tokenId);
  }

  /**
   * @dev 소유자가 토큰 승인하기
   */
  function approve(address _to, uint256 _tokenId) public virtual override {
    address owner = this.ownerOf(_tokenId);

    require(_to != owner, 'Approval to current owner');
    require(
      msg.sender == owner,
      'Approve caller is not owner nor approved for all'
    );

    _approve(_to, _tokenId);
  }

  /**
   * @dev 승인 여부 가져오기
   */
  function getApproved(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (address)
  {
    require(_exists(_tokenId), 'Operator query for nonexistent token');

    return _approvals[_tokenId];
  }

  /**
   * @dev 토큰 전송
   */
  function _transfer(
    address _from,
    address _to,
    uint256 _tokenId
  ) private {
    ownerProductCount[_from]--;
    ownerProductCount[_to]++;

    productToOwner[_tokenId] = _to;

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev 토큰 승인
   */
  function _approve(address _to, uint256 _tokenId) private {
    _approvals[_tokenId] = _to;

    emit Approval(this.ownerOf(_tokenId), _to, _tokenId);
  }

  /**
   * @dev 토큰 소유자 또는 결제자 승인 여부 반환
   */
  function _isApprovedOrOwner(address _spender, uint256 _tokenId)
    internal
    view
    returns (bool)
  {
    address owner = this.ownerOf(_tokenId);

    return (_spender == owner || getApproved(_tokenId) == _spender);
  }

  /**
   * @dev 토큰ID의 소유자 여부 반환
   */
  function _exists(uint256 _tokenId) internal view returns (bool) {
    return productToOwner[_tokenId] != address(0);
  }
}
