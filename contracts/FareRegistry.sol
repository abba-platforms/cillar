// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol"; import "@openzeppelin/contracts/security/Pausable.sol";

contract FareRegistry is Ownable, Pausable { struct FareInfo { uint256 nadFare;       // Fare in NAD (Namibian Dollars) uint256 usdConversion; // USD to NAD conversion rate (e.g., 18.00 NAD = 1 USD => 18 * 10^18) }

// region => zone => fare info
mapping(uint256 => mapping(uint256 => FareInfo)) public fares;

event FareUpdated(uint256 region, uint256 zone, uint256 nadFare, uint256 usdConversion);

constructor() {
    transferOwnership(msg.sender);
}

function setFare(
    uint256 region,
    uint256 zone,
    uint256 nadFare,
    uint256 usdConversion
) external onlyOwner whenNotPaused {
    require(nadFare > 0, "Fare must be > 0");
    require(usdConversion > 0, "Conversion must be > 0");
    fares[region][zone] = FareInfo(nadFare, usdConversion);
    emit FareUpdated(region, zone, nadFare, usdConversion);
}

function getFareInNAD(uint256 region, uint256 zone) external view returns (uint256) {
    FareInfo memory fare = fares[region][zone];
    return fare.nadFare;
}

function getFareInUSD(uint256 region, uint256 zone) external view returns (uint256) {
    FareInfo memory fare = fares[region][zone];
    require(fare.usdConversion > 0, "Conversion not set");
    return (fare.nadFare * 1e18) / fare.usdConversion; // returns fare in USD with 18 decimals
}

function batchSeedFares(
    uint256[] calldata regions,
    uint256[] calldata zones,
    uint256[] calldata nadFares,
    uint256[] calldata usdConversions
) external onlyOwner whenNotPaused {
    require(
        regions.length == zones.length &&
        zones.length == nadFares.length &&
        nadFares.length == usdConversions.length,
        "Input length mismatch"
    );
    require(regions.length <= 50, "Batch limit exceeded");

    for (uint256 i = 0; i < regions.length; i++) {
        fares[regions[i]][zones[i]] = FareInfo(nadFares[i], usdConversions[i]);
        emit FareUpdated(regions[i], zones[i], nadFares[i], usdConversions[i]);
    }
}

function pause() external onlyOwner {
    _pause();
}

function unpause() external onlyOwner {
    _unpause();
}

}

