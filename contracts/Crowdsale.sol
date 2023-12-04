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
    mapping(address => uint256) public vestingInfo; // Ajout du mapping pour stocker les informations de vesting
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    constructor(
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) Ownable(msg.sender) {
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = IERC20(addressOfTokenUsedAsReward);
    }

    function buy() payable public {
        require(!crowdsaleClosed);
        require(msg.value <= fundingGoal - amountRaised);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;

        // Ajout de la logique de vesting
        uint vestedAmount = calculateVestedAmount(amount);
        vestingInfo[msg.sender] += vestedAmount;

        tokenReward.transfer(msg.sender, vestedAmount / price);
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

    // Fonction pour calculer la quantité de tokens avec vesting
    function calculateVestedAmount( uint256 amount) internal view returns (uint256) {
        // Ajoutez votre logique de vesting ici, en fonction des besoins spécifiques de votre contrat
        // Cette fonction doit retourner la quantité de tokens qui seront débloqués immédiatement
        // Vous pouvez utiliser le mapping vestingInfo pour stocker des informations de vesting spécifiques à chaque contributeur
        // Exemple simple : 50% débloqué immédiatement, le reste après 30 jours
        uint256 immediateRelease = amount / 2;
        if (block.timestamp < deadline + 6 seconds) {
            return immediateRelease;
        } else {
            return amount;
        }
    }
}
