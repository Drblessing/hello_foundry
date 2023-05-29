// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/DiscreteStaking.sol";

IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/DiscreteStaking.t.sol
contract DiscreteTest is Test {
    DiscreteStakingRewards private discreteStaking =
        new DiscreteStakingRewards(
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );

    function testStaking() public {
        deal(address(WETH), address(this), 1e50);
        WETH.approve(address(discreteStaking), 1e50);

        discreteStaking.stake(1);
        discreteStaking.updateRewardIndex(10);

        console.log("rewardIndex", discreteStaking.rewardIndex());

        discreteStaking.updateRewardIndex(10);

        console.log("rewardIndex", discreteStaking.rewardIndex());
        
        discreteStaking.stake(1);
        discreteStaking.updateRewardIndex(10);

        console.log("rewardIndex", discreteStaking.rewardIndex());

        console.log("_calculateRewards", discreteStaking._calculateRewards(address(this)));
        console.log("balanceOf", discreteStaking.balanceOf(address(this)));




    }
}
