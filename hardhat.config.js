require('@nomiclabs/hardhat-waffle');

const fs = require('fs');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task('contracts', '컨트랙트 주소 정보', async () => {
  const contracts = getContractAddress();

  const keys = Object.keys(contracts);

  keys.forEach((key) => {
    console.log(`${key}: ${contracts[key]}`);
  });
});

task(
  'deploy',
  '컨트랙트 배포 및 주소 저장(.contracts.json)',
  async (taskArgs, hre) => {
    // ProductOwnership
    const ProductOwnership = await hre.ethers.getContractFactory(
      'ProductOwnership',
    );
    const productOwnership = await ProductOwnership.deploy();

    await productOwnership.deployed();

    console.log('ProductOwnership deployed to:', productOwnership.address);

    // Escrow
    const Escrow = await hre.ethers.getContractFactory('Escrow');
    const escrow = await Escrow.deploy(productOwnership.address);

    await escrow.deployed();

    console.log('Escrow deployed to:', escrow.address);

    // 컨트랙트 주소 json 파일로 저장
    const contracts = {
      ProductOwnership: productOwnership.address,
      Escrow: escrow.address,
    };

    fs.writeFileSync('./.contracts.json', JSON.stringify(contracts));
  },
);

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.4',
  defaultNetwork: 'localhost',
  networks: {
    hardhat: {
      chainId: 1337,
    },
    localhost: {
      url: 'http://localhost:8545',
    },
  },
};
