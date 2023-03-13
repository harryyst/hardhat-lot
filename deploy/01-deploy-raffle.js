const { network, ethers } = require('hardhat');
const {
  deploymentChains,
  networkConfig,
} = require('../helper-hardhat-config.js');
module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const VRF_SUB_FUND_AMOUNT = ethers.utils.parseEther('30');
  let vrfCoordinatorV2Address, subscriptionId;
  if (deploymentChains.includes(network.name)) {
    const VRFCoordinatorV2Mock = await ethers.getContract(
      'VRFCoordinatorV2Mock'
    );
    vrfCoordinatorV2Address = VRFCoordinatorV2Mock.address;
    const transRes = await VRFCoordinatorV2Mock.createSubscription();
    const transReceipt = await transRes.wait(1);
    subscriptionId = transReceipt.events[0].args.subId;
    await VRFCoordinatorV2Mock.fundSubscription(
      subscriptionId,
      VRF_SUB_FUND_AMOUNT
    );
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId]['vrfCoordinatorV2'];
    subscriptionId = networkConfig[chainId]['      subscriptionId'];
  }
  const entranceFee = networkConfig[chainId]['entranceFee'];
  const gasLane = networkConfig[chainId]['gasLane'];
  const callbackGasLimit = networkConfig[chainId]['callbackGasLimit'];
  const interval = networkConfig[chainId]['interval'];
  const args = [
    vrfCoordinatorV2Address,
    entranceFee,
    gasLane,
    subscriptionId,
    callbackGasLimit,
    interval,
  ];
  const raffle = await deploy('Raffle', {
    from: deployer,
    args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
};
