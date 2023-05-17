// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

contract Counter {
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        // Prevent underflows 
        if (count == 0) {
            return;
        }
        count--;
    }
}

contract MathTest is Test {

    // function testAssert(uint _i) pure external {
    //     assert(_i < 10);
    // }

//     function abs(uint x, uint y) private pure returns (uint) {
//         if (x >= y) {
//             return x - y;
//         }
//         return y - x;
//     }

//     function testAbs(uint x, uint y) external {
//         uint z = abs(x, y);
//         if (x >= y) {
// x            assertLe(z, x);
//         } else {
//             assertLe(z, y);
//         }
//     }
    // More complex example
    function abs(uint x, uint y) private pure returns (uint) {
        if (x >= y) {
            return x - y;
        }
        return y - x;
    }

    function test_abs(uint x, uint y) external {
        uint z = abs(x, y);
        if (x >= y) {
            assert(z <= x);
        } else {
            assert(z <= y);
        }
    }
}


contract CounterTest is Test {
    Counter counter;
    
    function setUp() public {
        counter = new Counter();
    }

    function testInc() public {
        counter.inc();
        assertEq(counter.count(), 1);
    }

    function testInc2() public {
        counter.inc();
        assertEq(counter.count(), 1);
    }

    function invariant_true() external {
        assertEq(true,true);
    }



}

