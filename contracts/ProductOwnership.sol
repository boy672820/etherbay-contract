//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductFactory.sol";

interface Ownership {
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _id) external view returns (address);
}

contract ProductOwnership is ProductFactory, Ownership {
    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return ownerProductCount[_owner];
    }

    function ownerOf(uint256 _id) external view override returns (address) {
        return productToOwner[_id];
    }
}
