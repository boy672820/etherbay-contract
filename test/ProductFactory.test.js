const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ProductFactory', async function () {
  let productFactory;
  let newProductEvents = [];

  const product = [
    'MacBook-pro M1X 16inch',
    'apple',
    'MacBook-pro M1X 16inch, Space Gray, 64GB Memory, 8TB SSD Storage, Pre-Installed "Final Cut Pro" and "Logic Pro"',
    'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/mbp16-spacegray-gallery2-202110?wid=4000&hei=3072&fmt=jpeg&qlt=80&.v=1632799174000',
  ];

  before(async function () {
    const Factory = await ethers.getContractFactory('ProductFactory');
    const factory = await Factory.deploy();
    await factory.deployed();

    productFactory = factory;
  });

  it('#1 상품 생성하기', async function () {
    const createProduct = await productFactory.createProduct(...product);

    const receipt = await createProduct.wait();

    const events = receipt.events.filter((x) => {
      return x.event == 'NewProduct';
    });
    newProductEvents = events;

    expect(events).to.not.length(0);
  });

  it('#2 추가된 상품 조회하기', async function () {
    const lastEvent = newProductEvents.pop();
    const productId = lastEvent.args.id.toNumber();

    const { name, category, description, image, ...hot } = await productFactory.products(productId);
    const newProduct = Object.values(hot);

    expect(newProduct).deep.to.equal(product);
  });
});
