require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
var task = require("hardhat/config").task;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    networks: {
        mumbai: {
            url: "https://polygon-mumbai.g.alchemy.com/v2/alcht_WtvbTgX0IGeYXhiWtsTcOyD4PxyiEX",
            accounts: [process.env.PRIVATE_KEY]
        }
    },
    etherscan: {
        apiKey: 'alcht_WtvbTgX0IGeYXhiWtsTcOyD4PxyiEX'
    },

    solidity: "0.8.20"
};

// hardhat.config.js

task("verify:get-contract-information", "Get contract information")
    .addParam("contractAddress", "The address of the deployed contract")
    .setAction(async ({ contractAddress }, hre) => {
        const { ethers } = hre;

        // Obtenez l'instance du contrat à partir de l'adresse
        const contract = await ethers.getContractAt("ContractName", contractAddress);

        // Obtenez des informations spécifiques sur le contrat
        const contractOwner = await contract.owner();
        const contractBalance = await ethers.provider.getBalance(contractAddress);

        // Affichez les informations
        console.log("Contract Owner:", contractOwner);
        console.log("Contract Balance:", ethers.utils.formatEther(contractBalance));
    });


