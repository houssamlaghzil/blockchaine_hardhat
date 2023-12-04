require("@nomicfoundation/hardhat-toolbox");
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
    solidity: "0.8.20",
    networks: {
        mumbai: {
            url: "https://rpc-mumbai.maticvigil.com/v1/b6458a5ff27ced3a6270009577979cb15e4fee8e",
            accounts: [process.env.PRIVATE_KEY]
        }
    },
    etherscan: {
        apiKey:process.env.POLYGONSCAN_API_KEY
    }
};
