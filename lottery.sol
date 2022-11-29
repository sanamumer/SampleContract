//SPDX-License-Identifier:UNLICENSED

pragma solidity 0.8.17;
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
// import "https://github.com/smartcontractkit/chainlink/blob/master/contracts/src/v0.8/VRFConsumerBase.sol";


contract Lottery is VRFConsumerBase{
   //0.01 ether for a ticket
    address payable[] public Player;
    uint256 public LotteryId;


    mapping (uint => address payable)public LotteryDetails;

    bytes32 internal keyHash;
    uint internal fee;
    uint public randomResult;

    constructor()VRFConsumerBase(
        0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D, // VRF coordinator
        0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK token address
    ){
        keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
            fee =  0.25 * 10 ** 18;  // 0.25LINK
            LotteryId = 1;
    }

    function getLinkBalance() public view returns (uint) {
        return LINK.balanceOf(address(this));
    }

    function setLottery()public payable{
        require(msg.value >= 0.01 ether,'INVALID AMOUNT!!');
        Player.push(payable(msg.sender));
    }

    function getRandomNumber()public returns(bytes32 requestId){
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

     function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
        randomResult = randomness;

    }

    function getWinner()public{
       
        uint index = randomResult % Player.length;
        Player[index].transfer(address(this).balance);

        LotteryDetails[LotteryId] = Player[index];
        LotteryId++;
        //reset
        Player = new address payable[](0);

    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return LotteryDetails[lottery];
    }

}