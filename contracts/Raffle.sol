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
    event RaffleEnter(address indexed player);

    constructor(address vrfV2,uint256 entranceFee) VRFConsumerBaseV2(vrfV2){
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfV2);
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

        i_vrfCoordinator.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

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
