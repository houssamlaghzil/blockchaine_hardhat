import {loadFixture, time} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {ethers} from "hardhat";
import {expect} from "chai";

describe("Counter", async function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployCounterFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Crowdsale = await ethers.getContractFactory("Crowdsale");
    const crowdsale = await Crowdsale.deploy(1,5,0.2,);

    return { counter: crowdsale, owner, otherAccount };
  }

  it("Should stay at zero", async function () {
    const { counter} = await loadFixture(deployCounterFixture);

    await counter.upCount()
    const count = await counter.getCount();
    expect(count).to.equal(0)
  });
})
