//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductFactory {
  event NewProduct(
    uint256 id,
    string indexed name,
    string category,
    string indexed description,
    string indexed image
  );

  struct Product {
    string name;
    string category;
    string description;
    string image;
  }

  Product[] private _products;

  mapping(uint256 => address) public productToOwner;
  mapping(address => uint256) public ownerProductCount;

  /**
   * @dev 상품 생성
   */
  function createProduct(
    string calldata _name,
    string calldata _category,
    string calldata _description,
    string calldata _image
  ) external {
    Product memory newProduct = Product(_name, _category, _description, _image);
    _products.push(newProduct);

    uint256 id = _products.length - 1;

    productToOwner[id] = msg.sender;
    ownerProductCount[msg.sender]++;

    emit NewProduct(id, _name, _category, _description, _image);
  }

  /**
   * @dev 상품 정보 가져오기
   */
  function getProduct(uint256 _id)
    external
    view
    returns (
      string memory,
      string memory,
      string memory,
      string memory
    )
  {
    return (
      _products[_id].name,
      _products[_id].category,
      _products[_id].description,
      _products[_id].image
    );
  }
}
