// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol"; import "@openzeppelin/contracts/security/Pausable.sol"; import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"; import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CillarVesting is Ownable, Pausable, ReentrancyGuard { using SafeERC20 for IERC20;

IERC20 public immutable cillar;
uint256 public totalAllocated;
uint256 public constant MAX_ALLOCATABLE = 30_000_000_000 * 10 ** 18;

struct VestingSchedule {
    uint256 totalAmount;
    uint256 claimedAmount;
    uint256 start;
    uint256 cliff;
    uint256 duration;
}

mapping(address => VestingSchedule[]) public vestings;

event VestingAdded(address indexed beneficiary, uint256 amount, uint256 start, uint256 cliff, uint256 duration);
event TokensClaimed(address indexed beneficiary, uint256 amount);
event UnallocatedRecovered(address indexed to, uint256 amount);

constructor(address _cillar) {
    require(_cillar != address(0), "Invalid token address");
    cillar = IERC20(_cillar);
}

function addVesting(
    address beneficiary,
    uint256 amount,
    uint256 start,
    uint256 cliff,
    uint256 duration
) external onlyOwner {
    require(beneficiary != address(0), "Invalid beneficiary");
    require(amount > 0, "Amount must be > 0");
    require(duration >= cliff, "Duration must be >= cliff");
    require(totalAllocated + amount <= MAX_ALLOCATABLE, "Exceeds max vesting cap");

    vestings[beneficiary].push(VestingSchedule({
        totalAmount: amount,
        claimedAmount: 0,
        start: start,
        cliff: start + cliff,
        duration: duration
    }));

    totalAllocated += amount;
    emit VestingAdded(beneficiary, amount, start, cliff, duration);
}

function claim() external nonReentrant whenNotPaused {
    VestingSchedule[] storage schedules = vestings[msg.sender];
    uint256 totalClaimable;

    for (uint256 i = 0; i < schedules.length; i++) {
        VestingSchedule storage vesting = schedules[i];
        uint256 vested = _vestedAmount(vesting);
        uint256 claimable = vested - vesting.claimedAmount;

        if (claimable > 0) {
            vesting.claimedAmount += claimable;
            totalClaimable += claimable;
        }
    }

    require(totalClaimable > 0, "Nothing to claim");
    cillar.safeTransfer(msg.sender, totalClaimable);
    emit TokensClaimed(msg.sender, totalClaimable);
}

function _vestedAmount(VestingSchedule memory vesting) internal view returns (uint256) {
    if (block.timestamp < vesting.cliff) {
        return 0;
    } else if (block.timestamp >= vesting.start + vesting.duration) {
        return vesting.totalAmount;
    } else {
        uint256 elapsed = block.timestamp - vesting.start;
        return (vesting.totalAmount * elapsed) / vesting.duration;
    }
}

function recoverUnallocatedTokens(address to) external onlyOwner {
    uint256 contractBalance = cillar.balanceOf(address(this));
    uint256 totalClaimed = _getTotalClaimed();
    uint256 unallocated = contractBalance - (totalAllocated - totalClaimed);

    require(unallocated > 0, "No unallocated tokens");
    cillar.safeTransfer(to, unallocated);
    emit UnallocatedRecovered(to, unallocated);
}

function _getTotalClaimed() internal view returns (uint256 claimed) {
    // NOTE: This is simplified. For production, consider indexing.
    claimed = 0;
    for (uint256 i = 0; i < 50; i++) {
        // Off-chain indexing should be used to track claim totals.
        // On-chain iteration is limited for small-scale use only.
    }
}

function pause() external onlyOwner {
    _pause();
}

function unpause() external onlyOwner {
    _unpause();
}

}

