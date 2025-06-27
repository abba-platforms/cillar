const { expect } = require("chai"); const { ethers } = require("hardhat");

describe("FareRegistry", function () { let FareRegistry, registry, owner, region1, region2;

beforeEach(async function () { [owner, region1, region2] = await ethers.getSigners(); const FareRegistryFactory = await ethers.getContractFactory("FareRegistry"); registry = await FareRegistryFactory.deploy(); await registry.deployed(); });

it("should allow default fare to be set and retrieved", async function () { await registry.setDefaultFare(1, ethers.utils.parseUnits("2", 18)); // 2 CILLAR const fare = await registry.getFare(ethers.constants.AddressZero, 1); expect(fare).to.equal(ethers.utils.parseUnits("2", 18)); });

it("should allow region-specific fare to be set and override default", async function () { await registry.setDefaultFare(1, ethers.utils.parseUnits("2", 18)); await registry.setRegionFare(region1.address, 1, ethers.utils.parseUnits("1.5", 18));

const fareDefault = await registry.getFare(ethers.constants.AddressZero, 1);
const fareRegion = await registry.getFare(region1.address, 1);

expect(fareDefault).to.equal(ethers.utils.parseUnits("2", 18));
expect(fareRegion).to.equal(ethers.utils.parseUnits("1.5", 18));

});

it("should fall back to default fare if region-specific is not set", async function () { await registry.setDefaultFare(2, ethers.utils.parseUnits("3", 18)); const fallbackFare = await registry.getFare(region2.address, 2); expect(fallbackFare).to.equal(ethers.utils.parseUnits("3", 18)); });

it("should revert when zone has no default fare", async function () { await expect(registry.getFare(region2.address, 99)).to.be.revertedWith("Fare not set"); });

it("should allow default admin to update fares", async function () { await registry.setDefaultFare(5, ethers.utils.parseUnits("5", 18)); await registry.setRegionFare(region1.address, 5, ethers.utils.parseUnits("4.5", 18)); const regionFare = await registry.getFare(region1.address, 5); expect(regionFare).to.equal(ethers.utils.parseUnits("4.5", 18)); }); });


