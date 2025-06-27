const { expect } = require("chai"); const { ethers } = require("hardhat");

describe("CillarCoin", function () { let CillarCoin, coin, owner, operator, user, treasury, fareRegistry; const initialSupply = ethers.utils.parseUnits("10000000000", 18); // 10B tokens

beforeEach(async function () { [owner, operator, user, treasury, fareRegistry] = await ethers.getSigners();

const FareRegistryMock = await ethers.getContractFactory("contracts/mocks/FareRegistryMock.sol:FareRegistryMock");
const fare = await FareRegistryMock.deploy();
await fare.deployed();

const CillarCoin = await ethers.getContractFactory("CillarCoin");
coin = await CillarCoin.deploy(fare.address, treasury.address);
await coin.deployed();

});

it("should deploy with correct name and symbol", async function () { expect(await coin.name()).to.equal("CillarCoin"); expect(await coin.symbol()).to.equal("CILLAR"); });

it("should assign total supply to owner", async function () { const balance = await coin.balanceOf(owner.address); expect(balance).to.equal(initialSupply); });

it("should allow admin to set KYC expiration", async function () { const future = Math.floor(Date.now() / 1000) + 3600; await coin.setKYC(user.address, future); const stored = await coin.kycExpirations(user.address); expect(stored).to.equal(future); });

it("should not allow ride payment without KYC", async function () { await expect(coin.connect(user).ridePayment(ethers.utils.id("ride1"), 1)) .to.be.revertedWith("KYC expired or not found"); });

it("should allow ride payment after KYC", async function () { const future = Math.floor(Date.now() / 1000) + 3600; await coin.setKYC(user.address, future);

await coin.transfer(user.address, ethers.utils.parseUnits("100", 18));
await coin.connect(user).approve(coin.address, ethers.utils.parseUnits("100", 18));

await coin.connect(user).ridePayment(ethers.utils.id("ride2"), 1);
const ride = await coin.rides(ethers.utils.id("ride2"));
expect(ride.confirmed).to.equal(true);
expect(ride.user).to.equal(user.address);

});

it("should apply operator fee on ride payment", async function () { const future = Math.floor(Date.now() / 1000) + 3600; await coin.setKYC(user.address, future); await coin.transfer(user.address, ethers.utils.parseUnits("100", 18)); await coin.connect(user).approve(coin.address, ethers.utils.parseUnits("100", 18));

await coin.connect(user).ridePayment(ethers.utils.id("ride3"), 1);
const balance = await coin.balanceOf(treasury.address);
expect(balance).to.be.gt(0);

});

it("should refund within window", async function () { const rideId = ethers.utils.id("ride4"); const future = Math.floor(Date.now() / 1000) + 3600; await coin.setKYC(user.address, future); await coin.transfer(user.address, ethers.utils.parseUnits("100", 18)); await coin.connect(user).approve(coin.address, ethers.utils.parseUnits("100", 18)); await coin.connect(user).ridePayment(rideId, 1); const pre = await coin.balanceOf(user.address);

await coin.grantRole(await coin.OPERATOR_ROLE(), owner.address);
await coin.refundRide(rideId);

const post = await coin.balanceOf(user.address);
expect(post).to.be.gt(pre);

}); });


