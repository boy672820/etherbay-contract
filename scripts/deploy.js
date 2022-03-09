const hre = require('hardhat');
const { ethers } = hre;

const fs = require('fs');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  console.log('Account balance:', (await deployer.getBalance()).toString());

  const EtherbayProduct = await hre.ethers.getContractFactory(
    'EtherbayProduct',
  );
  const etherbayProduct = await EtherbayProduct.deploy();

  await etherbayProduct.deployed();

  const network = hre.hardhatArguments.network || 'localhost';

  const contracts = {
    EtherbayProduct: etherbayProduct.address,
  };
  fs.writeFileSync(`./.${network}.contracts.json`, JSON.stringify(contracts));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
