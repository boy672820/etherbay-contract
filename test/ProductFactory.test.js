const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ProductFactory', async function () {
  let owner, user;
  let productOwnership;
  let newProductEvents = [], newProductId;

  const product = [
    'MacBook-pro M1X 16inch',
    'apple',
    'MacBook-pro M1X 16inch, Space Gray, 64GB Memory, 8TB SSD Storage, Pre-Installed "Final Cut Pro" and "Logic Pro"',
    'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/mbp16-spacegray-gallery2-202110?wid=4000&hei=3072&fmt=jpeg&qlt=80&.v=1632799174000',
  ];

  before(async function () {
    const [ownerSigner, addrSigner] = await ethers.getSigners();
    owner = ownerSigner;
    user = addrSigner;

    const Ownership = await ethers.getContractFactory('ProductOwnership');
    const ownership = await Ownership.deploy();

    await ownership.deployed();

    productOwnership = ownership;
  });

  it('#1 상품 생성하기', async function () {
    const createProduct = await productOwnership.connect(user).createProduct(...product);

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
    newProductId = productId;

    const [...hot] = await productOwnership.getProduct(productId);
    const productOwner = hot.pop();

    expect(hot).deep.to.equal(product);
    expect(productOwner).to.equal(user.address);
  });

  it('#3 Ownable 체크', async function () {
    const balanceOf = await productOwnership.balanceOf(user.address);
    const ownerOf = await productOwnership.ownerOf(newProductId);

    expect(balanceOf.toNumber()).to.equal(1);
    expect(ownerOf).to.equal(user.address);
  });
});
