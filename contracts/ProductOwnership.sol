//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ProductFactory.sol';

contract ProductOwnership is ProductFactory {
  function balanceOf(address _owner) public view returns (uint256) {
    return ownerProductCount[_owner];
  }

  function ownerOf(uint256 _id) public view returns (address) {
    return productToOwner[_id];
  }
}
