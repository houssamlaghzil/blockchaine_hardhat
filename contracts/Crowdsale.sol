// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importe le contrat Ownable d'OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Définit le contrat Crowdsale, qui est Ownable
contract Crowdsale is Ownable {
    // Déclare des variables d'état
    uint public fundingGoal;             // Objectif de collecte de fonds en Ether
    uint public amountRaised;            // Montant total collecté jusqu'à présent
    uint public deadline;                // Date limite de la campagne de financement
    uint public price;                   // Prix d'un jeton en Ether
    IERC20 public tokenReward;           // Adresse du contrat du jeton utilisé comme récompense
    mapping(address => uint256) public balanceOf; // Solde de chaque contributeur
    bool public fundingGoalReached = false;       // Indique si l'objectif de collecte a été atteint
    bool public crowdsaleClosed = false;          // Indique si la campagne de financement est close

    // Événements pour enregistrer des logs
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    // Constructeur pour initialiser le contrat Crowdsale, en appelant également le constructeur Ownable
    constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) Ownable() {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = IERC20(addressOfTokenUsedAsReward);
    }

    // Fonction fallback pour recevoir de l'Ether et distribuer des jetons
    function () payable public {
        // Assurez-vous que la campagne de financement est toujours ouverte
        require(!crowdsaleClosed);

        // Enregistre la contribution de l'expéditeur
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;

        // Transfère des jetons à l'expéditeur en fonction de l'Ether envoyé
        tokenReward.transfer(msg.sender, amount / price);

        // Émet un événement pour enregistrer le transfert de fonds
        emit FundTransfer(msg.sender, amount, true);
    }

    // Modificateur pour vérifier si le temps actuel est après la date limite de financement
    modifier afterDeadline() {
        if (block.timestamp >= deadline)
            _;
    }

    // Fonction pour vérifier si l'objectif de collecte a été atteint après la date limite
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;

            // Émet un événement pour enregistrer l'atteinte de l'objectif
            emit GoalReached(beneficiary, amountRaised);
        }
    }

    // Fonction pour retirer les jetons si l'objectif de collecte est atteint
    function withdrawTokens() public onlyOwner afterDeadline{
        uint unsoldTokens = tokenReward.balanceOf(address(this)) - amountRaised / price;
        if (unsoldTokens > 0) {
            // Transfère tous les jetons invendus au propriétaire
            tokenReward.transfer(owner(), unsoldTokens);
        }
    }

    // Fonction pour retirer les fonds si l'objectif de collecte est atteint
    function withdrawFunds() public onlyOwner afterDeadline{
        // Transfère l'intégralité du solde au propriétaire
        payable(owner()).transfer(address(this).balance);
    }
}
