// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

contract MyUniV3Flash {
    IUniswapV3Pool constant pool =
        IUniswapV3Pool(0x11950d141EcB863F01007AdD7D1A342041227b58);
    address public constant pepe = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    function flash(uint256 amountPepe, uint256 amountWETH) external {
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount0: amountPepe,
                amount1: amountWETH,
                caller: msg.sender
            })
        );

        pool.flash(address(this), amountPepe, amountWETH, data);
    }

    function uniswapV3FlashCallback(
        uint fee0,
        uint fee1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool), "not authorized");

        FlashCallbackData memory decodedFlashCallbackData = abi.decode(
            data,
            (FlashCallbackData)
        );

        // Log fee
        console.log("fee0: %s Pepe", fee0);
        console.log("fee1: %s WETH", fee1);

        // Repay borrow
        IERC20(pepe).transfer(address(pool), fee0 + decodedFlashCallbackData.amount0);
        IERC20(weth).transfer(address(pool), fee1 + decodedFlashCallbackData.amount1);
    }
}

interface IUniswapV3Pool {
    function flash(
        address recipient,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}
