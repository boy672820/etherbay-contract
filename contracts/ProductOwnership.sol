//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ProductFactory.sol';

contract ProductOwnership is ProductFactory {
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address productToOwner, address to, uint256 tokenId);

    mapping(uint256 => address) private _approvals;

    function balanceOf(address _owner) public view returns (uint256) {
        return ownerProductCount[_owner];
    }

    function ownerOf(uint256 _id) public view returns (address) {
        return productToOwner[_id];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {}

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

    function _approve(address _to, uint256 _tokenId) private {
        _approvals[_tokenId] = _to;

        emit Approval(this.ownerOf(_tokenId), _to, _tokenId);
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId)
        internal
        view
        returns (bool)
    {}
}
