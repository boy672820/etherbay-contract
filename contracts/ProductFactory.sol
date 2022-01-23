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

  Product[] public products;

  function createProduct(
    string calldata _name,
    string calldata _category,
    string calldata _description,
    string calldata _image
  ) external {
    Product memory newProduct = Product(_name, _category, _description, _image);
    products.push(newProduct);

    uint256 id = products.length - 1;

    emit NewProduct(id, _name, _category, _description, _image);
  }
}
