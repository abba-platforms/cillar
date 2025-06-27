// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FareRegistry is AccessControl { bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

struct FareConfig {
    uint256 localFare;
    uint256 longFare;
    uint256 seniorDiscountPercent;
}

mapping(uint256 => FareConfig) public regionFares;
uint256 public exchangeRate; // NAD to USD (multiplied by 1e18)

event FareSet(uint256 indexed region, uint256 localFare, uint256 longFare);
event ExchangeRateUpdated(uint256 newRate);
event DiscountUpdated(uint256 indexed region, uint256 percent);

constructor(uint256 _exchangeRate) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(OPERATOR_ROLE, msg.sender);
    exchangeRate = _exchangeRate;
}

function setRegionFares(
    uint256 region,
    uint256 localFare,
    uint256 longFare
) external onlyRole(DEFAULT_ADMIN_ROLE) {
    regionFares[region].localFare = localFare;
    regionFares[region].longFare = longFare;
    emit FareSet(region, localFare, longFare);
}

function setSeniorDiscount(uint256 region, uint256 percent) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(percent <= 100, "Invalid discount");
    regionFares[region].seniorDiscountPercent = percent;
    emit DiscountUpdated(region, percent);
}

function getFare(uint256 region, uint256 zone) external view returns (uint256) {
    FareConfig memory cfg = regionFares[region];
    return zone <= 1 ? cfg.localFare : cfg.longFare;
}

function getDiscountedFare(
    uint256 region,
    uint256 zone,
    bool isSenior
) external view returns (uint256) {
    uint256 fare = zone <= 1 ? regionFares[region].localFare : regionFares[region].longFare;
    if (isSenior) {
        uint256 discount = (fare * regionFares[region].seniorDiscountPercent) / 100;
        return fare - discount;
    }
    return fare;
}

function updateExchangeRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(newRate > 0, "Invalid rate");
    exchangeRate = newRate;
    emit ExchangeRateUpdated(newRate);
}

function getExchangeRate() external view returns (uint256) {
    return exchangeRate;
}

}


