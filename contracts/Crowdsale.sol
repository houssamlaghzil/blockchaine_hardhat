// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract Crowdsale is Ownable {
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    IERC20 public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    constructor(
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) Ownable(msg.sender) {  // Appel au constructeur de la classe parente Ownable
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = IERC20(addressOfTokenUsedAsReward);
    }

    function buy() payable public {
        require(!crowdsaleClosed);
        console.log("msg.value: %s", msg.value);
        console.log("fundingGoal: %s", fundingGoal);
        console.log("amountRaised: %s", amountRaised);
        console.log(msg.value ,'<=', fundingGoal - amountRaised);
        console.log(msg.value <= fundingGoal - amountRaised);
        require(msg.value <= fundingGoal - amountRaised);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        emit FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() {
        if (block.timestamp >= deadline)
            _;
    }

    function withdrawTokens() public onlyOwner afterDeadline {
        uint unsoldTokens = tokenReward.balanceOf(address(this)) - amountRaised / price;
        if (unsoldTokens > 0) {
            tokenReward.transfer(owner(), unsoldTokens);
        }
    }

    function withdrawFunds() public onlyOwner afterDeadline {
        payable(owner()).transfer(address(this).balance);
    }
}
