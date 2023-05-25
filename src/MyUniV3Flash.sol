// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";

contract MyUniV3Flash {
    IUniswapV3Pool constant pool =
        IUniswapV3Pool(0x11950d141EcB863F01007AdD7D1A342041227b58);
    address public constant pepe = 0x6982508145454Ce325dDbE47a25d4ec3d2311933;

    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    ISwapRouter constant router =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;

    uint160 internal constant MAX_SQRT_RATIO =
        1461446703485210103287273052203988822378723970342;

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    function flash(uint256 amountPepe, uint256 amountWETH) public {
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

        // Repay borrow
        IERC20(pepe).transfer(address(pool), fee0 + decodedFlashCallbackData.amount0);
        IERC20(weth).transfer(address(pool), fee1 + decodedFlashCallbackData.amount1);
    }

    // Sell Weth for PEPE
    function swap(uint amountIn) external {
        bool zeroForOne = false;
        uint160 sqrtPriceLimitX96 = MAX_SQRT_RATIO - 1;
        bytes memory data = abi.encode(address(pool), amountIn);

        pool.swap(address(this), zeroForOne, int(amountIn), sqrtPriceLimitX96, data);
    }

    function uniswapV3SwapCallback(
        int amount0,
        int amount1,
        bytes calldata data
    ) external {
        // Check amounts after swap
        console.log("Callback");

        uint amountPepe = IERC20(pepe).balanceOf(address(this)) / 1e18;
        uint amountWETH = IERC20(weth).balanceOf(address(this)) / 1e18;

        console.log(amountPepe);
        console.log(amountWETH);

        (address pool_, uint amountIn) = abi.decode(data, (address, uint));

        console.log("Amount in ", amountIn);

        require(msg.sender == address(pool), "not authorized");

        uint amountOut = uint(-amount0);

        console.log("Amount out", amountOut);

        IERC20(weth).transfer(address(pool), amountIn);
    }
}

interface IUniswapV3Pool {
    function flash(
        address recipient,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;

    function swap(
        address recipient,
        bool zeroForOne,
        int amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int amount0, int amount1);
}

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint amountOut);
}
