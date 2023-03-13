const { network, ethers } = require('hardhat');
const { deploymentChains } = require('../helper-hardhat-config.js');
const BASE_FEE = ethers.utils.parseEther('0.25');
const GAS_PRICE_LINK = 1e9;
module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const args = [BASE_FEE, GAS_PRICE_LINK];

  if (deploymentChains.includes(network.name)) {
    log('deploying!!');
    await deploy('VRFCoordinatorV2Mock', {
      from: deployer,
      log: true,
      args,
    });
    log('Mocks deploy');
    log('------------');
  }
};
module.exports.tags = ['all', 'mock'];
