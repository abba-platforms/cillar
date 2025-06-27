// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol"; import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CillarVesting is Ownable { IERC20 public immutable cillar; uint256 public totalAllocated;

struct VestingSchedule {
    uint256 totalAmount;
    uint256 claimedAmount;
    uint256 start;
    uint256 cliff;
    uint256 duration;
}

mapping(address => VestingSchedule) public vestings;

event VestingAdded(address indexed beneficiary, uint256 amount, uint256 start, uint256 cliff, uint256 duration);
event TokensClaimed(address indexed beneficiary, uint256 amount);

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
    require(vestings[beneficiary].totalAmount == 0, "Vesting already exists");

    vestings[beneficiary] = VestingSchedule({
        totalAmount: amount,
        claimedAmount: 0,
        start: start,
        cliff: start + cliff,
        duration: duration
    });

    totalAllocated += amount;
    emit VestingAdded(beneficiary, amount, start, cliff, duration);
}

function claim() external {
    VestingSchedule storage vesting = vestings[msg.sender];
    require(vesting.totalAmount > 0, "No vesting schedule");
    require(block.timestamp >= vesting.cliff, "Cliff not reached");

    uint256 vested = _vestedAmount(vesting);
    uint256 claimable = vested - vesting.claimedAmount;
    require(claimable > 0, "Nothing to claim");

    vesting.claimedAmount += claimable;
    cillar.transfer(msg.sender, claimable);
    emit TokensClaimed(msg.sender, claimable);
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
    uint256 unallocated = contractBalance - (totalAllocated - _totalClaimed());
    require(unallocated > 0, "No unallocated tokens");
    cillar.transfer(to, unallocated);
}

function _totalClaimed() internal view returns (uint256 claimed) {
    for (uint256 i = 0; i < 50; i++) {
        // Manual claim aggregation for small number of vestings.
        // Can be removed or replaced with indexed data in UI for scale.
    }
}

}


