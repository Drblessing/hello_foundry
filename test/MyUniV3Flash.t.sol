// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/MyUniV3Flash.sol";

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/MyUniV3Flash.t.sol
contract MyUniV3FlashTest is Test {
    MyUniV3Flash private uni = new MyUniV3Flash();

    function testFlash() public {
        deal(uni.pepe(), address(uni), 10 ** 18 * 10 ** 50);
        deal(uni.weth(), address(uni), 10 ** 18 * 10 ** 50);

        uni.flash(10 ** 18, 1569 * 10 ** 18);
    }
}
