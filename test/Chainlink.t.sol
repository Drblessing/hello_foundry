// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/ChainlinkPriceoracle.sol";

// forge test -vv --gas-report --fork-url https://eth.llamarpc.com --mp test/Chainlink.t.sol
contract ChainlinkTest is Test {
    ChainlinkPriceOracle private chainlink = new ChainlinkPriceOracle();

    function testPrice() public view {
        console.logInt(chainlink.getLatestPrice());
    }
}
