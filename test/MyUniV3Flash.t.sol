// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/MyUniV3Flash.sol";

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/MyUniV3Flash.t.sol
contract MyUniV3FlashTest is Test {
    MyUniV3Flash private uni = new MyUniV3Flash();

    function testFlash() public {
        deal(uni.pepe(), address(uni), 1e18 * 1e12);
        deal(uni.weth(), address(uni), 1e18 * 1e12);

        uni.flash(10 ** 18, 1000 * 10 ** 18);
    }

    function testSwap() public {
        deal(uni.pepe(), address(uni), 1e18 * 1e20);
        deal(uni.weth(), address(uni), 1e18 * 1e20);

        uint startingPepe = IERC20(uni.pepe()).balanceOf(address(uni)) / 10 ** 18;
        uint startingWeth = IERC20(uni.weth()).balanceOf(address(uni)) / 10 ** 18;

        console.log(startingPepe);
        console.log(startingWeth);

        uni.swap(10 ** 18);

        uint endingPepe = IERC20(uni.pepe()).balanceOf(address(uni)) / 10 ** 18;
        uint endingWeth = IERC20(uni.weth()).balanceOf(address(uni)) / 10 ** 18;

        console.log(endingPepe);
        console.log(endingWeth);
    }
}
