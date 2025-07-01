// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; import "@openzeppelin/contracts/access/AccessControl.sol"; import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IFareRegistry { function getDiscountedFare(uint256 region, uint256 zone, bool isSenior) external view returns (uint256); function getExchangeRate() external view returns (uint256); }

contract CillarCoin is ERC20, AccessControl { using SafeERC20 for IERC20;

bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10 ** 18;
uint256 public operatorFeePercent = 10;
uint256 public baseRewardAmount = 1 * 10 ** 18;
uint256 public rewardThreshold = 20;
uint256 public minFareForReward = 2 * 10 ** 18;
uint256 public refundWindow = 48 hours;

uint256 public totalRewardsDistributed;
uint256 public rideCount;

address public fareRegistry;
address public treasury;

AggregatorV3Interface public priceFeed;
uint256 public lastRewardAdjustment;
uint256 public rewardDecayInterval = 30 days;
uint256 public rewardDecayPercent = 10;

struct Ride {
    bool confirmed;
    bool refunded;
    uint256 farePaid;
    uint256 timestamp;
    address user;
}

mapping(bytes32 => Ride) public rides;
mapping(address => uint256) public kycExpirations;

event RidePaid(bytes32 indexed rideId, address indexed user, uint256 amount);
event RideRefunded(bytes32 indexed rideId, address indexed user, uint256 amount);
event RideMetadataLogged(bytes32 indexed rideId, uint8 zone, string start, string end, string mode);
event KYCSet(address indexed user, uint256 expiration);
event RewardDistributed(address indexed rider, uint256 amount);
event OperatorFeeUpdated(uint256 newFee);
event FareRegistryUpdated(address newRegistry);
event TreasuryWithdrawal(address admin, uint256 amount);
event RewardParametersUpdated(uint256 baseAmount, uint256 decayInterval, uint256 decayPercent);

constructor(
    address _fareRegistry,
    address _treasury,
    address vestingContract,
    address _priceFeed
) ERC20("CillarCoin", "CILLAR") {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(OPERATOR_ROLE, msg.sender);

    fareRegistry = _fareRegistry;
    treasury = _treasury;
    priceFeed = AggregatorV3Interface(_priceFeed);

    uint256 initialMint = 10_000_000_000 * 10 ** decimals();
    _mint(msg.sender, initialMint);

    uint256 vestingSupply = 30_000_000_000 * 10 ** decimals();
    _mint(vestingContract, vestingSupply);

    lastRewardAdjustment = block.timestamp;
}

modifier onlyKYCed() {
    require(block.timestamp <= kycExpirations[msg.sender], "KYC expired or not found");
    _;
}

function getLatestUsdPrice() public view returns (uint256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    require(price > 0, "Invalid price");
    return uint256(price);
}

function setKYC(address user, uint256 expiration) external onlyRole(DEFAULT_ADMIN_ROLE) {
    kycExpirations[user] = expiration;
    emit KYCSet(user, expiration);
}

function ridePayment(bytes32 rideId, uint256 region, uint256 zone, bool isSenior) external onlyKYCed {
    require(!rides[rideId].confirmed, "Ride already paid");

    uint256 nadFare = IFareRegistry(fareRegistry).getDiscountedFare(region, zone, isSenior);
    uint256 usdFare = (nadFare * 1e18) / IFareRegistry(fareRegistry).getExchangeRate();
    uint256 usdPrice = getLatestUsdPrice();
    uint256 cillarAmount = (usdFare * 1e8 * 10 ** decimals()) / usdPrice;
    uint256 operatorFee = (cillarAmount * operatorFeePercent) / 100;

    _transfer(msg.sender, address(this), cillarAmount);
    _transfer(address(this), treasury, operatorFee);

    rides[rideId] = Ride(true, false, cillarAmount, block.timestamp, msg.sender);
    emit RidePaid(rideId, msg.sender, cillarAmount);

    _processReward(msg.sender, cillarAmount);
}

function ridePaymentStablecoin(bytes32 rideId, uint256 stableAmount) external onlyKYCed {
    require(!rides[rideId].confirmed, "Ride already paid");
    require(stableAmount > 0 && stableAmount < 1_000_000 * 1e18, "Invalid amount");

    rides[rideId] = Ride(true, false, stableAmount, block.timestamp, msg.sender);
    emit RidePaid(rideId, msg.sender, stableAmount);
    _processReward(msg.sender, stableAmount);
}

function refundRide(bytes32 rideId) external onlyRole(OPERATOR_ROLE) {
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
    emit TreasuryWithdrawal(msg.sender, amount);
}

function setOperatorFeePercent(uint256 percent) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(percent <= 100, "Invalid percent");
    operatorFeePercent = percent;
    emit OperatorFeeUpdated(percent);
}

function setFareRegistry(address newRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
    fareRegistry = newRegistry;
    emit FareRegistryUpdated(newRegistry);
}

function updateRewardParameters(uint256 newBaseAmount, uint256 newInterval, uint256 newPercent) external onlyRole(DEFAULT_ADMIN_ROLE) {
    baseRewardAmount = newBaseAmount;
    rewardDecayInterval = newInterval;
    rewardDecayPercent = newPercent;
    emit RewardParametersUpdated(newBaseAmount, newInterval, newPercent);
}

function logRideMetadata(bytes32 rideId, uint8 zone, string calldata start, string calldata end, string calldata mode) external {
    require(hasRole(OPERATOR_ROLE, msg.sender), "Only operator");
    require(rides[rideId].confirmed, "Ride must exist");
    emit RideMetadataLogged(rideId, zone, start, end, mode);
}

function burn(uint256 amount) external {
    _burn(msg.sender, amount);
}

function burnFrom(address account, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    _burn(account, amount);
}

function _mint(address to, uint256 amount) internal override {
    require(totalSupply() + amount <= MAX_SUPPLY, "CILLAR: Exceeds max supply");
    super._mint(to, amount);
}

function _processReward(address rider, uint256 farePaid) internal {
    if (farePaid >= minFareForReward) {
        rideCount++;
        if (rideCount % rewardThreshold == 0) {
            if (block.timestamp >= lastRewardAdjustment + rewardDecayInterval) {
                baseRewardAmount = (baseRewardAmount * (100 - rewardDecayPercent)) / 100;
                lastRewardAdjustment = block.timestamp;
            }
            uint256 nextReward = baseRewardAmount;
            require(totalSupply() + nextReward <= MAX_SUPPLY, "CILLAR: Exceeds max supply");
            _mint(rider, nextReward);
            totalRewardsDistributed += nextReward;
            emit RewardDistributed(rider, nextReward);
        }
    }
}

}

