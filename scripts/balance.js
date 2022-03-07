const hre = require('hardhat');

async function main() {
  const EtherbayProduct = await hre.ethers.getContractFactory(
    'EtherbayProduct',
  );
  const product = await EtherbayProduct.attach(
    '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  );

  const [owner, user] = await hre.ethers.getSigners();
  const supply = (await product.balanceOf(user.address)).toString();

  console.log(supply);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
