const { expect } = require("chai"); const { ethers } = require("hardhat");

const ONE_DAY = 24 * 60 * 60;

describe("CillarVesting", function () { let Token, Vesting, token, vesting, owner, beneficiary;

beforeEach(async function () { [owner, beneficiary] = await ethers.getSigners();

Token = await ethers.getContractFactory("CillarCoin");
token = await Token.deploy(owner.address, owner.address);
await token.deployed();

const VestingFactory = await ethers.getContractFactory("CillarVesting");
vesting = await VestingFactory.deploy(token.address);
await vesting.deployed();

await token.transfer(vesting.address, ethers.utils.parseUnits("1000", 18));

});

it("should allow admin to add vesting schedule", async function () { await vesting.addVestingSchedule( beneficiary.address, Math.floor(Date.now() / 1000) + ONE_DAY, ONE_DAY, 2, ethers.utils.parseUnits("100", 18) );

const schedule = await vesting.vestingSchedules(beneficiary.address);
expect(schedule.totalAmount).to.equal(ethers.utils.parseUnits("100", 18));

});

it("should not release before start time", async function () { const now = Math.floor(Date.now() / 1000); await vesting.addVestingSchedule(beneficiary.address, now + ONE_DAY, ONE_DAY, 2, ethers.utils.parseUnits("100", 18)); await expect(vesting.connect(beneficiary).release()).to.be.revertedWith("Nothing to release yet"); });

it("should release correct amount after one interval", async function () { const now = (await ethers.provider.getBlock("latest")).timestamp; await vesting.addVestingSchedule(beneficiary.address, now + 1, ONE_DAY, 2, ethers.utils.parseUnits("100", 18));

await ethers.provider.send("evm_increaseTime", [ONE_DAY + 2]);
await ethers.provider.send("evm_mine");

await vesting.connect(beneficiary).release();
const balance = await token.balanceOf(beneficiary.address);
expect(balance).to.equal(ethers.utils.parseUnits("50", 18));

});

it("should release full amount after all intervals", async function () { const now = (await ethers.provider.getBlock("latest")).timestamp; await vesting.addVestingSchedule(beneficiary.address, now + 1, ONE_DAY, 2, ethers.utils.parseUnits("100", 18));

await ethers.provider.send("evm_increaseTime", [2 * ONE_DAY + 2]);
await ethers.provider.send("evm_mine");

await vesting.connect(beneficiary).release();
const balance = await token.balanceOf(beneficiary.address);
expect(balance).to.equal(ethers.utils.parseUnits("100", 18));

});

it("should revert if vesting schedule already exists", async function () { const start = Math.floor(Date.now() / 1000) + 1; await vesting.addVestingSchedule(beneficiary.address, start, ONE_DAY, 2, ethers.utils.parseUnits("100", 18)); await expect( vesting.addVestingSchedule(beneficiary.address, start, ONE_DAY, 2, ethers.utils.parseUnits("100", 18)) ).to.be.revertedWith("Schedule already exists"); }); });


