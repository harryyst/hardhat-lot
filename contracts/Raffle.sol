// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__notEnoughEntranceFee();

contract Raffle is VRFConsumerBaseV2{

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subId; 
    uint16 private constant requestConfirmations=3;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant numWords = 1;

    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(address vrfV2,uint256 entranceFee,bytes32 gasLane,uint64 subId,uint32 callbackGasLimit) VRFConsumerBaseV2(vrfV2){
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfV2);
        i_gasLane = gasLane;
        i_subId=subId;
        i_callbackGasLimit = callbackGasLimit;
    }
    
    function enterRaffle()public payable {
        if(msg.value<i_entranceFee){
            revert Raffle__notEnoughEntranceFee();
        }else{
            s_players.push(payable(msg.sender));
            emit RaffleEnter(msg.sender);
        }

    }

    function requestPickerRadomWinner()external{

        uint256 requestId= i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subId,
            requestConfirmations,
            i_callbackGasLimit,
            numWords
        );

        emit RequestedRaffleWinner(requestId);

    }

    function fulfillRandomWords(uint256 requestid,uint256[] memory randomWords )internal override{

    }

    function getEntranceFee()public view returns(uint256){
        return i_entranceFee;
    }
    function getPlayer(uint256 index)public view returns(address){
        return s_players[index];
    }
}
