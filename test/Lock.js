const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {ethers} = require("hardhat");
const {expect} = require("chai");
const {sleep} = require("@nomicfoundation/hardhat-verify/internal/utilities");

describe("Counter", async function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployCrowdsaleFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const ERC20 = await ethers.getContractFactory("MYTOKEN");
        const Crowdsale = await ethers.getContractFactory("Crowdsale");

        const erc20 = await ERC20.deploy();
        const crowdsale = await Crowdsale.deploy(10,10,1,erc20.getAddress());
        erc20.transfer(crowdsale.getAddress(), 1000000);

        return { crowdsale, owner, otherAccount };
    }

    it('tentative d achat', async () => {
        const [owner, otherAccount] = await ethers.getSigners();
        const {crowdsale} = await loadFixture(deployCrowdsaleFixture);
        await crowdsale.connect(otherAccount).buy(
            {value: 1}
        );
        expect(await crowdsale.balanceOf(otherAccount.address)).to.equal(1);
    });

    it('tentative d achat sans avoir assez de token', async () => {
        const [owner, otherAccount] = await ethers.getSigners();
        const {crowdsale} = await loadFixture(deployCrowdsaleFixture);
        await expect(crowdsale.connect(otherAccount).buy(
            {value: ethers.parseUnits("10000000000000000001","wei")}
        )).to.be.reverted;
    }
    );

})
