pragma solidity ^0.8.0;

interface IProductOwnership {
  event Transfer(address from, address to, uint256 tokenId);
  event Approval(address productToOwner, address to, uint256 tokenId);

  function balanaceOf(address _owner) external view returns (uint256);

  function ownerOf(uint256 _tokenId) external view returns (address);

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) external;

  function approve(address _to, uint256 _tokenId) external;

  function getApproved(uint256 _tokenId) external view returns (address);
}
