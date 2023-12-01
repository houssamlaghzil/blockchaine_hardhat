// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = hre.ethers.parseEther("0.001");

  const MYTOKEN = await hre.ethers.deployContract("MYTOKEN");

  await MYTOKEN.waitForDeployment();

  const Crowdsale = await hre.ethers.deployContract("Crowdsale", [10,10,1,MYTOKEN.address]);

  await Crowdsale.waitForDeployment();

  await MYTOKEN.transfer(Crowdsale.address, 1000000);

  
  console.log(
    `Lock with ${ethers.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${MYTOKEN.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
