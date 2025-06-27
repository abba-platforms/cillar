
// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; import "@openzeppelin/contracts/access/AccessControl.sol";

contract CillarCoin is ERC20, AccessControl { bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

// Config
uint256 public cillarUsdPrice = 10 * 10 ** 16; // $0.10
uint256 public operatorFeePercent = 10;
uint256 public rewardAmount = 1 * 10 ** decimals();
uint256 public rewardThreshold = 20;
uint256 public minFareForReward = 2 * 10 ** decimals();
uint256 public refundWindow = 48 hours;
uint256 public lastPriceUpdate;
uint256 public priceUpdateCooldown = 1 hours;

address public fareRegistry;
address public treasury;
uint256 public rideCount;

struct Ride {
    bool confirmed;
    bool refunded;
    uint256 farePaid;
    uint256 timestamp;
    address user;
}

mapping(bytes32 => Ride) public rides;
mapping(address => uint256) public kycExpirations;

event RidePaid(bytes32 rideId, address indexed user, uint256 amount);
event RideRefunded(bytes32 rideId, address indexed user, uint256 amount);
event CillarPriceUpdated(uint256 newPrice);
event RideMetadataLogged(bytes32 rideId, uint8 zone, string start, string end, string mode);

constructor(address _fareRegistry, address _treasury) ERC20("CillarCoin", "CILLAR") {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(OPERATOR_ROLE, msg.sender);
    fareRegistry = _fareRegistry;
    treasury = _treasury;
    _mint(msg.sender, 10_000_000_000 * 10 ** decimals());
}

modifier onlyKYCed() {
    require(block.timestamp <= kycExpirations[msg.sender], "KYC expired or not found");
    _;
}

function updateCillarUsdPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(block.timestamp >= lastPriceUpdate + priceUpdateCooldown, "Cooldown not met");
    uint256 lowerBound = (cillarUsdPrice * 90) / 100;
    uint256 upperBound = (cillarUsdPrice * 110) / 100;
    require(newPrice >= lowerBound && newPrice <= upperBound, "Price deviation too high");
    cillarUsdPrice = newPrice;
    lastPriceUpdate = block.timestamp;
    emit CillarPriceUpdated(newPrice);
}

function setKYC(address user, uint256 expiration) external onlyRole(DEFAULT_ADMIN_ROLE) {
    kycExpirations[user] = expiration;
}

function ridePayment(bytes32 rideId, uint256 region, uint256 zone, bool isSenior) external onlyKYCed {
    require(!rides[rideId].confirmed, "Ride already paid");

    uint256 nadFare = IFareRegistry(fareRegistry).getDiscountedFare(region, zone, isSenior);
    uint256 usdFare = (nadFare * 1e18) / IFareRegistry(fareRegistry).getExchangeRate();
    uint256 cillarAmount = (usdFare * 10 ** decimals()) / cillarUsdPrice;
    uint256 operatorFee = (cillarAmount * operatorFeePercent) / 100;

    _transfer(msg.sender, address(this), cillarAmount);
    _transfer(address(this), treasury, operatorFee);

    rides[rideId] = Ride(true, false, cillarAmount, block.timestamp, msg.sender);
    emit RidePaid(rideId, msg.sender, cillarAmount);

    _processReward(msg.sender, cillarAmount);
}

function ridePaymentStablecoin(bytes32 rideId, uint256 stableAmount) external onlyKYCed {
    require(!rides[rideId].confirmed, "Ride already paid");
    rides[rideId] = Ride(true, false, stableAmount, block.timestamp, msg.sender);
    emit RidePaid(rideId, msg.sender, stableAmount);
    _processReward(msg.sender, stableAmount);
}

function refundRide(bytes32 rideId) external {
    require(hasRole(OPERATOR_ROLE, msg.sender), "Only operator");
    Ride storage ride = rides[rideId];
    require(ride.confirmed, "Ride not confirmed");
    require(!ride.refunded, "Already refunded");
    require(block.timestamp <= ride.timestamp + refundWindow, "Refund window expired");

    ride.refunded = true;
    _transfer(treasury, ride.user, ride.farePaid);
    emit RideRefunded(rideId, ride.user, ride.farePaid);
}

function withdrawTreasuryBalance(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _transfer(address(this), treasury, amount);
}

function setOperatorFeePercent(uint256 percent) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(percent <= 100, "Invalid percent");
    operatorFeePercent = percent;
}

function logRideMetadata(bytes32 rideId, uint8 zone, string calldata start, string calldata end, string calldata mode) external {
    require(hasRole(OPERATOR_ROLE, msg.sender), "Only operator");
    require(rides[rideId].user == msg.sender, "Not ride owner");
    emit RideMetadataLogged(rideId, zone, start, end, mode);
}

function burn(uint256 amount) external {
    _burn(msg.sender, amount);
}

function burnFrom(address account, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _burn(account, amount);
}

function _processReward(address rider, uint256 farePaid) internal {
    if (farePaid >= minFareForReward) {
        rideCount++;
        if (rideCount % rewardThreshold == 0) {
            _mint(rider, rewardAmount);
        }
    }
}

function setFareRegistry(address newRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
    fareRegistry = newRegistry;
}

}

interface IFareRegistry { function getDiscountedFare(uint256 region, uint256 zone, bool isSenior) external view returns (uint256); function getExchangeRate() external view returns (uint256); }

