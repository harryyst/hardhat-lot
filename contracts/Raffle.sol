// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol';

error Raffle__notEnoughEntranceFee();
error Raffle__TransferFail();
error Raffle__NotOpen();
error Raffle__UpKeepNotNeeded();

contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
  enum RaffleState {
    OPEN,
    CALCULATING
  }
  uint256 private immutable i_entranceFee;
  address payable[] private s_players;
  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  bytes32 private immutable i_gasLane;
  uint64 private immutable i_subId;
  uint16 private constant requestConfirmations = 3;
  uint32 private immutable i_callbackGasLimit;
  uint16 private constant numWords = 1;
  uint256 private s_lastTimeStamp;
  uint256 private immutable i_interval;
  address private s_recentWinner;
  RaffleState private s_raffleState;

  event RaffleEnter(address indexed player);
  event RequestedRaffleWinner(uint256 indexed requestId);
  event WinnerPicked(address indexed winner);

  constructor(
    address vrfV2,
    uint256 entranceFee,
    bytes32 gasLane,
    uint64 subId,
    uint32 callbackGasLimit,
    uint256 interval
  ) VRFConsumerBaseV2(vrfV2) {
    i_entranceFee = entranceFee;
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfV2);
    i_gasLane = gasLane;
    i_subId = subId;
    i_callbackGasLimit = callbackGasLimit;
    s_raffleState = RaffleState.OPEN;
    s_lastTimeStamp = block.timestamp;
    i_interval = interval;
  }

  function enterRaffle() public payable {
    if (msg.value < i_entranceFee) {
      revert Raffle__notEnoughEntranceFee();
    }
    if (s_raffleState != RaffleState.OPEN) {
      revert Raffle__NotOpen();
    }
    s_players.push(payable(msg.sender));
    emit RaffleEnter(msg.sender);
  }

  function performUpkeep(bytes calldata /* checkData */) external override {
    (bool upKeepNeed, ) = checkUpkeep('');
    if (!upKeepNeed) {
      revert Raffle__UpKeepNotNeeded();
    }
    s_raffleState = RaffleState.CALCULATING;
    uint256 requestId = i_vrfCoordinator.requestRandomWords(
      i_gasLane,
      i_subId,
      requestConfirmations,
      i_callbackGasLimit,
      numWords
    );

    emit RequestedRaffleWinner(requestId);
  }

  function fulfillRandomWords(
    uint256 /*requestid*/,
    uint256[] memory randomWords
  ) internal override {
    uint256 indexOfWinner = randomWords[0] % s_players.length;
    address payable recentWinner = s_players[indexOfWinner];
    s_recentWinner = recentWinner;
    s_raffleState = RaffleState.OPEN;
    s_lastTimeStamp = block.timestamp;
    s_players = new address payable[](0);
    (bool success, ) = recentWinner.call{ value: address(this).balance }('');
    if (!success) {
      revert Raffle__TransferFail();
    }
    emit WinnerPicked(recentWinner);
  }

  function checkUpkeep(
    bytes memory /* checkData */
  )
    public
    override
    returns (bool upkeepNeeded, bytes memory /* performData */)
  {
    bool isOpen = (RaffleState.OPEN == s_raffleState);
    bool timeStamp = ((block.timestamp - s_lastTimeStamp) > i_interval);
    bool hasPlayer = s_players.length > 0;
    bool hasBalance = address(this).balance > 0;
    upkeepNeeded = (isOpen && timeStamp && hasPlayer && hasBalance);
  }

  function getEntranceFee() public view returns (uint256) {
    return i_entranceFee;
  }

  function getPlayer(uint256 index) public view returns (address) {
    return s_players[index];
  }

  function getRecentWinner() public view returns (address) {
    return s_recentWinner;
  }
}
