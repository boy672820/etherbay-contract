const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('EtherbayProduct', async function () {
  let owner, user, user2;
  let product;

  before(async function () {
    const [ownerSigner, userSigner, userSigner2] = await ethers.getSigners();
    owner = ownerSigner;
    user = userSigner;
    user2 = userSigner2;

    const Product = await ethers.getContractFactory('EtherbayProduct');
    product = await Product.deploy();

    await product.deployed();

    const name = await product.name();
    const symbol = await product.symbol();

    expect([name, symbol]).to.deep.equal(['Etherbay Product', 'EBP']);
  });

  const jsonUri =
    'https://gateway.pinata.cloud/ipfs/Qmddr94PsC89ENMnEBk6WhxxBP8cbDGYNfeAJscqgwRCSM';

  it('#1 토큰 발급 테스트', async function () {
    const tx = await product.mint(user.address, jsonUri);
    const receipt = await tx.wait();
    const { tokenId } = receipt.events[0].args;

    // 소유자 확인
    const owner = await product.ownerOf(tokenId);
    expect(owner).to.equal(user.address);

    // 토큰 uri 확인
    const uri = await product.tokenURI(tokenId);
    expect(uri).to.equal(jsonUri);
  });

  it('#2 ERC721 Enumerable', async function () {
    await Promise.all([
      product.mint(user.address, jsonUri),
      product.mint(user.address, jsonUri),
      product.mint(user.address, jsonUri),
    ]);

    const balance = await product.balanceOf(user.address);
    let total = balance.toNumber(),
      ownerTokens = [];

    while (total > 0) {
      total -= 1;

      const tokenId = await product.tokenOfOwnerByIndex(user.address, total);
      ownerTokens.push(tokenId);
    }

    expect(ownerTokens).to.be.a('array');
  });
});
