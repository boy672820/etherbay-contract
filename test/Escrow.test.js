const { expect } = require('chai');
const { ethers } = require('hardhat');
const { BigNumber } = require('ethers');

describe('Escrow', async function () {
  let owner, user, spender;
  let productOwnership, escrow;
  let newProductEvents = [],
    newProductId;

  const product = [
    'MacBook-pro M1X 16inch',
    'apple',
    'MacBook-pro M1X 16inch, Space Gray, 64GB Memory, 8TB SSD Storage, Pre-Installed "Final Cut Pro" and "Logic Pro"',
    'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/mbp16-spacegray-gallery2-202110?wid=4000&hei=3072&fmt=jpeg&qlt=80&.v=1632799174000',
  ];

  before(async function () {
    const [ownerSigner, addrSigner, addr2Signer] = await ethers.getSigners();
    owner = ownerSigner;
    user = addrSigner;
    spender = addr2Signer;

    // ProductOwnership 컨트랙트 배포
    const Ownership = await ethers.getContractFactory('ProductOwnership');
    const ownershipInstance = await Ownership.deploy();

    await ownershipInstance.deployed();

    productOwnership = ownershipInstance;

    // Escrow 컨트랙트 배포
    const Escrow = await ethers.getContractFactory('Escrow');
    const escrowInstance = await Escrow.deploy(productOwnership.address);

    await escrowInstance.deployed();

    escrow = escrowInstance;
  });

  it('#1 상품 생성하기', async function () {
    const createProduct = await productOwnership
      .connect(user)
      .createProduct(...product);

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

    expect(hot).deep.to.equal(product);
  });

  it('#3 상품 에스크로 등록하기', async function () {
    const amount = ethers.utils.parseEther('1.25'); // 1.25 ETH
    const openTrade = await escrow.connect(user).openTrade(newProductId, amount);

    const receipt = await openTrade.wait();
    const events = receipt.events.filter((x) => {
      return x.event == 'TradeStatusChange';
    });

    console.log(events);
  });
});
