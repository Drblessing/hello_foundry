// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate-utils/CREATE3.sol";

contract Counter {
    uint256 public number = 10;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
