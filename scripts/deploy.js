// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {ethers} = require("hardhat");
const {sleep} = require("@nomicfoundation/hardhat-verify/internal/utilities");

async function main() {
  const MYTOKEN = await ethers.getContractFactory("MYTOKEN");
  const myToken = await MYTOKEN.deploy();

  await myToken.waitForDeployment();

  // const Crowdsale = await ethers.getContractFactory("Crowdsale", [10,10,1,MYTOKEN.address]);
  const Crowdsale = await ethers.getContractFactory("Crowdsale");
  const crowdsale = await Crowdsale.deploy( 10,10,1, await myToken.getAddress());

  await crowdsale.waitForDeployment();

  await myToken.transfer( await crowdsale.getAddress(), 1000000);
  console.log("Crowdsale deployed to:", await crowdsale.getAddress());
  console.log("erc deployed to:", await myToken.getAddress());

  await sleep(60000)

  await hre.run('verify:verify', {
    address: await crowdsale.getAddress(),
    constructorArguments: [10,10,1, await myToken.getAddress()],
    contract: 'contracts/Crowdsale.sol:Crowdsale',

  })
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
