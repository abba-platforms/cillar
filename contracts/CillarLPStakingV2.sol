// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract CillarLPStaking is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public lpToken;       // CILLAR-BNB LP token
    IERC20 public rewardToken;   // CILLAR token

    uint256 public rewardPerBlock;   // Reward per block
    uint256 public totalStaked;
    uint256 public lastRewardBlock;
    uint256 public accRewardPerShare; // Accumulated rewards per share (scaled 1e12)
    uint256 public minStakeBlocks;    // Minimum blocks before withdraw

    // Optional timestamp-based staking
    mapping(address => uint256) public depositTimestamp;

    struct UserInfo {
        uint256 amount;       // LP tokens staked
        uint256 rewardDebt;   // Reward debt
        uint256 depositBlock; // Block when user deposited
    }

    mapping(address => UserInfo) public userInfo;

    // Early-bird bonus mapping
    mapping(address => uint256) public bonusRewards;

    // Multisig admin address for production governance
    address public multisigAdmin;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardWithdrawn(uint256 amount, address to);
    event RewardPerBlockUpdated(uint256 newRate);
    event MinStakeBlocksUpdated(uint256 newMinStake);
    event Paused(address by);
    event Unpaused(address by);
    event EarlyBirdReward(address user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == multisigAdmin || msg.sender == owner(), "Not admin");
        _;
    }

    constructor(
        IERC20 _lpToken,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _minStakeBlocks,
        address _multisigAdmin
    ) {
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        minStakeBlocks = _minStakeBlocks;
        lastRewardBlock = block.number;
        multisigAdmin = _multisigAdmin;
    }

    // Update pool rewards
    function updatePool() public whenNotPaused {
        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = block.number - lastRewardBlock;
        uint256 reward = blocks * rewardPerBlock;
        accRewardPerShare += (reward * 1e12) / totalStaked;
        lastRewardBlock = block.number;
    }

    // Deposit LP tokens
    function deposit(uint256 _amount) external nonReentrant whenNotPaused {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;
            if (pending > 0) {
                rewardToken.safeTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.amount += _amount;
            totalStaked += _amount;
            user.depositBlock = block.number;
            depositTimestamp[msg.sender] = block.timestamp;
        }

        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;
        emit Deposit(msg.sender, _amount);
    }

    // Withdraw LP tokens and claim rewards
    function withdraw(uint256 _amount) external nonReentrant whenNotPaused {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Not enough staked");
        require(block.number >= user.depositBlock + minStakeBlocks, "Min stake period not met");

        updatePool();

        uint256 pending = (user.amount * accRewardPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            rewardToken.safeTransfer(msg.sender, pending);
        }

        if (_amount > 0) {
            user.amount -= _amount;
            totalStaked -= _amount;
            lpToken.safeTransfer(msg.sender, _amount);
        }

        user.rewardDebt = (user.amount * accRewardPerShare) / 1e12;
        emit Withdraw(msg.sender, _amount, pending);
    }

    // View pending rewards
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 tempAccRewardPerShare = accRewardPerShare;

        if (totalStaked != 0) {
            uint256 blocks = block.number - lastRewardBlock;
            uint256 reward = blocks * rewardPerBlock;
            tempAccRewardPerShare += (reward * 1e12) / totalStaked;
        }

        return (user.amount * tempAccRewardPerShare) / 1e12 - user.rewardDebt;
    }

    // Emergency withdraw LP without rewards
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amount = user.amount;
        require(amount > 0, "Nothing to withdraw");

        user.amount = 0;
        user.rewardDebt = 0;
        totalStaked -= amount;
        lpToken.safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    // Admin: Adjust reward rate
    function setRewardPerBlock(uint256 _newRate) external onlyAdmin {
        rewardPerBlock = _newRate;
        emit RewardPerBlockUpdated(_newRate);
    }

    // Admin: Adjust minimum staking period
    function setMinStakeBlocks(uint256 _blocks) external onlyAdmin {
        minStakeBlocks = _blocks;
        emit MinStakeBlocksUpdated(_blocks);
    }

    // Admin: Emergency withdraw remaining reward tokens
    function emergencyRewardWithdraw(uint256 _amount, address _to) external onlyAdmin {
        rewardToken.safeTransfer(_to, _amount);
        emit RewardWithdrawn(_amount, _to);
    }

    // Admin: Pause/unpause contract
    function pause() external onlyAdmin {
        _pause();
        emit Paused(msg.sender);
    }

    function unpause() external onlyAdmin {
        _unpause();
        emit Unpaused(msg.sender);
    }

    // Optional: Award early-bird bonus to user
    function awardEarlyBird(address _user, uint256 _amount) external onlyAdmin {
        bonusRewards[_user] += _amount;
        rewardToken.safeTransfer(_user, _amount);
        emit EarlyBirdReward(_user, _amount);
    }

    // Admin: Change multisig admin
    function setMultisigAdmin(address _newAdmin) external onlyOwner {
        multisigAdmin = _newAdmin;
    }
}
