//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductFactory {
  event NewProduct(
    uint256 id,
    string name,
    string category,
    string description,
    string image
  );

  struct Product {
    string name;
    string category;
    string description;
    string image;
  }

  Product[] private products;

  mapping (uint256 => address) internal productToOwner;
  mapping (address => uint256) internal ownerProductCount;

  function createProduct(
    string calldata _name,
    string calldata _category,
    string calldata _description,
    string calldata _image
  ) external {
    Product memory newProduct = Product(_name, _category, _description, _image);
    products.push(newProduct);

    uint256 id = products.length - 1;

    productToOwner[id] = msg.sender;
    ownerProductCount[msg.sender] ++;

    emit NewProduct(id, _name, _category, _description, _image);
  }

  function getProduct(uint256 _id)
    external
    view
    returns (
      string memory,
      string memory,
      string memory,
      string memory,
      address
    )
  {
    return (
      products[_id].name,
      products[_id].category,
      products[_id].description,
      products[_id].image,
      productToOwner[_id]
    );
  }
}
