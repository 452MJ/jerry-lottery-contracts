const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
    time
} = require('@openzeppelin/test-helpers');

describe("LotteryTicketPool", function() {

    let Token;
    let hardhatToken;
    let alice;
    let bob;
    beforeEach(async function() {
        Token = await ethers.getContractFactory('BettingPool');
        [alice, bob] = await ethers.getSigners();
        hardhatToken = await Token.deploy();
    });

    it("Start round 1", async() => {
        expect(await hardhatToken.totalBonus()).to.equal(0);
        await hardhatToken.addBonus({ value: ethers.utils.parseEther('1') });
        await hardhatToken.addBonus({ value: ethers.utils.parseEther('1') });
        await time.increase(time.duration.days(1));
        await hardhatToken.connect(bob).addBonus({ value: ethers.utils.parseEther('1') });
        expect(await hardhatToken.totalBonus()).to.equal(ethers.utils.parseEther('2'));
        expect(await hardhatToken.checkBonus(alice.address)).to.equal(ethers.utils.parseEther('1'));
        expect(await hardhatToken.checkBonus(bob.address)).to.equal(ethers.utils.parseEther('1'));
    })

    // it("Check Alice bonus", async() => {
    //     expect(await hardhatToken.checkBonus(alice.address)).to.equal(1);
    //
    // })


    // it('Total bonus equal 0.1ETH', async function() {
    //     expect(await hardhatToken.totalBonus()).to.equal(0);
    // });
});
