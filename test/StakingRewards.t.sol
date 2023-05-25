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
        deal(address(WETH), address(stakingRewards), 1e18 * 1e12);
        deal(address(WETH), address(this), 1e18 * 1e12);

        stakingRewards.setRewardsDuration(86400);
        stakingRewards.notifyRewardAmount(1000 * 10 ** 18);

        // approve stakingRewards to spend WETH
        WETH.approve(address(stakingRewards), 1e30);
        stakingRewards.stake(1e18);

        // Increase time by 1 day using vm.warp
        vm.warp(block.timestamp + 86400);

        // Before any actions taken
        console.log("Earned:", stakingRewards.earned(address(this)));
        console.log("rewardPerToken:", stakingRewards.rewardPerToken());
        console.log("rewardPerTokenStored:", stakingRewards.rewardPerTokenStored());
        console.log("updatedAt:", stakingRewards.updatedAt());
        console.log("finishAt:", stakingRewards.finishAt());
        console.log(
            "userRewardPerTokenPaid:",
            stakingRewards.userRewardPerTokenPaid(address(this))
        );
        console.log("Current timestamp:", block.timestamp);
    }
}
