const { ethers } = require('hardhat');

const networkConfig = {
  5: {
    name: 'goerli',
    vrfCoordinatorV2: '0x271682DEB8C4E0901D1a1550aD2e64D568E69909',
    entranceFee: ethers.utils.parseEther('0.01'),
    gasLane:
      '0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef',
    subscriptionId: '0',
    callbackGasLimit: '500000',
    interval: '30',
  },
  31337: {
    name: 'hardhat',
    entranceFee: ethers.utils.parseEther('0.01'),
    gasLane:
      '0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef',
  },
  callbackGasLimit: '500000',
  interval: '30',
};
const developementChains = ['har dhat', 'localhost'];

module.exports = {
  networkConfig,
  developementChains,
};
