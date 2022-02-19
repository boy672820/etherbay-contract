const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('EtherbayProduct', async function () {
  let owner, user;
  let product;

  before(async function () {
    const [ownerSigner, userSigner] = await ethers.getSigners();
    owner = ownerSigner;
    user = userSigner;

    const Product = await ethers.getContractFactory('EtherbayProduct');
    product = await Product.deploy();

    await product.deployed();

    const name = await product.name();
    const symbol = await product.symbol();

    expect([name, symbol]).to.deep.equal(['Etherbay Product', 'EBP']);
  });

  it('#1 토큰 발급 테스트', async function () {
    const tx = await product.mint(user.address, 'test');
    const receipt = await tx.wait();
    const { tokenId } = receipt.events[0].args;

    const owner = await product.ownerOf(tokenId);

    expect(owner).to.equal(user.address);
  });
});
