//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProductOwnership {
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event Approval(
    address indexed productToOwner,
    address indexed to,
    uint256 indexed tokenId
  );

  function balanceOf(address _owner) external view returns (uint256);

  function ownerOf(uint256 _tokenId) external view returns (address);

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) external;

  function approve(address _to, uint256 _tokenId) external;

  function getApproved(uint256 _tokenId) external view returns (address);
}
