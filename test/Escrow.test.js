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

  it('#3 상품 승인하기', async function () {
    await productOwnership.connect(user).approve(escrow.address, newProductId);

    const approved = await productOwnership.getApproved(newProductId);

    expect(approved).to.equal(escrow.address);
  });

  let newTradeId;

  it('#3 상품 에스크로 등록하기', async function () {
    const amount = ethers.utils.parseEther('1000'); // 1000 ETH
    const openTrade = await escrow
      .connect(user)
      .openTrade(newProductId, amount);

    const receipt = await openTrade.wait();
    const events = receipt.events.filter((x) => {
      return x.event == 'TradeStatusChange';
    });

    const { status, tradeId } = events[0].args;
    newTradeId = tradeId;

    expect(status).to.equal('open');

    const ownerOf = await productOwnership.ownerOf(newProductId);

    expect(ownerOf).to.equal(escrow.address);
  });

  it('#4 에스크로에 등록된 상품확인', async function () {
    const { poster, status } = await escrow.trades(newTradeId);

    const targetTrade = [poster, ethers.utils.parseBytes32String(status)];
    const expectTrade = [user.address, 'open'];

    expect(targetTrade).to.deep.equal(expectTrade);
  });

  it('#5 에스크로에 등록된 상품 구매하기', async function () {
    const amount = ethers.utils.parseEther('1000');

    const executeTrade = await escrow
      .connect(spender)
      .executeTrade(newTradeId, { value: amount });

    const receipt = await executeTrade.wait();
    const events = receipt.events.filter((x) => {
      return x.event == 'TradeStatusChange';
    });

    const { status } = events[0].args;

    expect(status).to.equal('executed');
  });

  it('#6 에스크로에 등록된 상품 구매 확정하기', async function () {
    const confirmTrade = await escrow.connect(user).confirmTrade(newTradeId);

    const receipt = await confirmTrade.wait();
    const events = receipt.events.filter((x) => {
      return x.event == 'TradeStatusChange';
    });

    const { status } = events[0].args;

    expect(status).to.equal('confirmed');

    const ownerOf = await productOwnership.ownerOf(newProductId);

    expect(ownerOf).to.equal(spender.address);
  });

  it('#0 ProductOwnership 컨트랙트 변경하기', async function () {
    const Ownership = await ethers.getContractFactory('ProductOwnership');
    const ownershipInstance = await Ownership.deploy();

    await ownershipInstance.deployed();

    await escrow.setProductOwnership(ownershipInstance.address);

    const escrowProductAddress = await escrow.product();

    expect(escrowProductAddress).to.equal(ownershipInstance.address);
  });
});
