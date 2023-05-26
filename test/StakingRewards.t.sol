// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/StakingRewards.sol";

IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/StakingRewards.t.sol
contract StakingRewardsTest is Test {
    StakingRewards private stakingRewards =
        new StakingRewards(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );

    function testTrue() public {
        deal(address(WETH), address(stakingRewards), 86400 * 10);
        deal(address(WETH), address(this), 1);

        stakingRewards.setRewardsDuration(86400);
        stakingRewards.notifyRewardAmount(86400 * 10);

        // approve stakingRewards to spend WETH
        WETH.approve(address(stakingRewards), 1e30);

        // Stake
        stakingRewards.stake(1);

        // Increase time by using vm.warp
        vm.warp(block.timestamp + 86400 - 1);

        vm.startPrank(address(0x1));

        deal(address(WETH), address(0x1), 1);
        WETH.approve(address(stakingRewards), 1e30);
        stakingRewards.stake(1);

        vm.stopPrank();

        vm.warp(block.timestamp + 1);

        // withdraw stake
        stakingRewards.withdraw(1);

        // claim rewards
        stakingRewards.getReward();
    }

    function testOverflow() public {
        deal(address(WETH), address(stakingRewards), 1e18);
        deal(address(WETH), address(this), 1e77);
        WETH.approve(address(stakingRewards), 1e77);
        stakingRewards.stake(1e77);

        vm.startPrank(address(0x1));
        deal(address(WETH), address(0x1), 1e77);
        WETH.approve(address(stakingRewards), 1e77);
        vm.expectRevert(stdError.arithmeticError);
        stakingRewards.stake(1e77);
        vm.stopPrank();
    }

    function testExploit() public {
        // There is a bug that allows a user/owner to increase rewards beyond the total supply
        // if the rewards and staking tokens are the same.
        // because the contract uses rewardsToken.balanceOf()

        // Setup:
        deal(address(WETH), address(this), 1e50);
        deal(address(WETH), address(0x1), 1e18);
        deal(address(WETH), address(0x2), 10);
        WETH.approve(address(stakingRewards), 1e50);

        vm.startPrank(address(0x1));
        WETH.approve(address(stakingRewards), 1e50);
        vm.stopPrank();

        vm.startPrank(address(0x2));
        WETH.approve(address(stakingRewards), 1e50);
        vm.stopPrank();

        // 1) Deploy contract with same staking and rewards token

        // 2) Malicious user/owner stakes a large amount of tokens
        stakingRewards.stake(1e40);

        // 3) Owner calls duration and notifyRewardAmount with a large amount,
        // either by accident or on purpose.
        // This will cause the rewards to be greater than the total supply.
        // After user unstakes.
        stakingRewards.setRewardsDuration(1e6);
        stakingRewards.notifyRewardAmount(1e40);

        // rewardRate = 1e40 / 1e6 = 1e34
        // console.log("rewardRate: %s", stakingRewards.rewardRate());

        // 4) User unstakes
        stakingRewards.withdraw(1e40);

        // 5) Other user stakes
        vm.startPrank(address(0x1));
        stakingRewards.stake(1e18);

        // 6) Increase timesetamp by 1 second
        vm.warp(block.timestamp + 1);

        // 7) User tries to claim rewards
        // This will cause the contract to revert because the rewards are greater than the total supply
        // Rewards = 1e34 * 1 = 1e34
        // Contract balance = 1e16

        // console.log("User rewards: %s", stakingRewards.earned(address(0x1)));

        vm.expectRevert(bytes(""));
        stakingRewards.getReward();

        // 8) User can still withdraw
        stakingRewards.withdraw(1e18);
        vm.stopPrank();

        // 9) However, if another person stakes a tiny amount, they can steal
        // other people's staked tokens.
        // Contract WETH balance is 0 at this point.

        // 10) 0x2 stakes 10 wei
        vm.startPrank(address(0x2));
        stakingRewards.stake(10);
        vm.stopPrank();

        // 11) 0x1 stakes 1e18
        vm.startPrank(address(0x1));
        stakingRewards.stake(1e18);
        vm.stopPrank();

        // 12) Increase time by 1 second
        vm.warp(block.timestamp + 1);

        // 13) 0x2 claims rewards
        // 0x2 earned = 1e34 * 10 / 1e18 = 1e17
        // 0x1 earned = 1e34 * 1e18 / 1e18 = 1e34

        // console.log("0x2 earned: %s", stakingRewards.earned(address(0x2)));
        vm.startPrank(address(0x2));
        stakingRewards.getReward();
        stakingRewards.withdraw(10);
        vm.stopPrank();

        console.log("0x2 WETH balance: %s", WETH.balanceOf(address(0x2)));
        // 1e16

        console.log(
            "0x1 staking balanceOf: %s",
            stakingRewards.balanceOf(address(0x1))
        );

        console.log(
            "Staking rewards WETH balance: %s",
            WETH.balanceOf(address(stakingRewards))
        );

        // 14) 0x1 tries to withdraw
        // This will revert because the contract has only 1e18 - 1e17 WETH
        // 0x1 is owed 1e18 WETH
        vm.startPrank(address(0x1));
        vm.expectRevert(bytes(""));
        stakingRewards.withdraw(1e18);
        vm.stopPrank();
        // 0x1 has lost 1e17 WETH
        // New members can have their tokens stolen by old members
        // The contract has no way to recover from this, because
        // the remainingRewards are too high for the owner to pay back,
        // and the rewardRate can't be upated if reward amount > balance.
    }
}

/* 
Notes on testing:

First experiment: 
walkthrough of calculations
1) Set reward duration to 86400, and notifyRewardAmount(1e6)
2) when notifyRewardAmount is called, it updatesRewards(0)
3) rewardPerToken() = 0 (since totalSupply = 0, and rewardPerTokenStored = 0)
4) rewardPerTokenStored = 0
5) updatedAt = lastTimeRewardApplicable() = block.timestamp
6) back to notifyRewardAmount
7) remainingRewards = 0

Invariants:
1) rewardPerTokenStored always increases
2) userRewardPerTokenPaid always increases
3) rewards[user] is always calculated before userRewardPerTokenPaid[user] is updated

Multiple users staking:
The way the variables are caluclated, it doesn't matter the order or number of users. 
Earned is calculated by multiplying the difference between rewardPerTokenStored and userRewardPerTokenPaid by the number of tokens staked.
This ensures that users will get tokens in proportion to the amount of time they have staked.
*/
