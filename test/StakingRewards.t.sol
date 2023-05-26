// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/StakingRewards.sol";

IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/StakingRewards.sol
contract StakingRewardsTest is Test {
    StakingRewards private stakingRewards =
        new StakingRewards(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );

    function testTrue() public {
        console.log("Starting block timestamp:", block.timestamp);
        deal(address(WETH), address(stakingRewards), 86400 * 10);
        deal(address(WETH), address(this), 1);

        stakingRewards.setRewardsDuration(86400);
        stakingRewards.notifyRewardAmount(86400 * 10);

        console.log("Reward rate", stakingRewards.rewardRate());

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

        console.log("Reward per token stored", stakingRewards.rewardPerTokenStored());
        console.log("Reward per token", stakingRewards.rewardPerToken());

        // console.log("Reward token balance:", WETH.balanceOf(address(stakingRewards)));
        // console.log("Earned:", stakingRewards.earned(address(this)));
        // console.log("Total supply:", stakingRewards.totalSupply());
        // console.log("rewardPerToken:", stakingRewards.rewardPerToken());
        // console.log("rewardPerTokenStored:", stakingRewards.rewardPerTokenStored());
        // console.log("updatedAt:", stakingRewards.updatedAt());
        // console.log("finishAt:", stakingRewards.finishAt());
        // console.log(
        //     "userRewardPerTokenPaid:",
        //     stakingRewards.userRewardPerTokenPaid(address(this))
        // );
        // console.log("Current timestamp:", block.timestamp);

        // claim rewards
        stakingRewards.getReward();

        // check weth balance
        console.log("Reward token balance this:", WETH.balanceOf(address(this)));
        console.log(
            "Reward token balance staking:",
            WETH.balanceOf(address(stakingRewards))
        );
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
8) 
*/
