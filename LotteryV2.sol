//SPDX-License-Identifier:UNLICENSED

pragma solidity 0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract Lottery is VRFConsumerBaseV2{
    VRFCoordinatorV2Interface COORDINATOR;
    address payable[] public Players;
    uint256 public LotteryId;
    address public lastWinner;
    uint256 public Result;

    event LotteryEnter(address indexed player);
    event RequestLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    uint64  s_subscriptionId;
    address vrfCoordinator =0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =1;

    constructor(uint64 subscriptionId)VRFConsumerBaseV2(vrfCoordinator){
         s_subscriptionId = subscriptionId;
         COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
         LotteryId = 1;

    }

    function setLottery()public payable{
        require(msg.value >= 0.01 ether,'INVALID AMOUNT!!');
        Players.push(payable(msg.sender));
         emit LotteryEnter(msg.sender);
    }

    function getRandomNumber()public{
     uint256 requestId =  COORDINATOR.requestRandomWords( 
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit RequestLotteryWinner(requestId);
       
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
        ) internal override {
        uint256 indexOfWinner = randomWords[0] % Players.length;
         Result = indexOfWinner;
        address payable LastWinner = Players[indexOfWinner];
        lastWinner = LastWinner;
        LotteryId++;
        Players = new address payable[](0);
        emit WinnerPicked(LastWinner);
    }


}
