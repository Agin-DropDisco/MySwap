pragma solidity =0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./dexSwapv2/interfaces/IDEXswapERC20.sol";
import "./dexSwapv2/interfaces/IDEXswapPair.sol";
import "./dexSwapv2/interfaces/IDEXswapFactory.sol";

contract DEXswapMaker {
    using SafeMath for uint256;

    IDEXswapFactory public factory;
    address public bar;
    address public dexs;
    address public weth;

    constructor(
        IDEXswapFactory _factory,
        address _bar,
        address _dexs,
        address _weth
    ) public {
        factory = _factory;
        dexs = _dexs;
        bar = _bar;
        weth = _weth;
    }

    function convert(address token0, address token1) public {
        // At least we try to make front-running harder to do.
        require(msg.sender == tx.origin, "do not convert from contract");
        IDEXswapPair pair = IDEXswapPair(factory.getPair(token0, token1));
        pair.transfer(address(pair), pair.balanceOf(address(this)));
        pair.burn(address(this));
        uint256 wethAmount = _toWETH(token0) + _toWETH(token1);
        _toDEXS(wethAmount);
    }

    function _toWETH(address token) internal returns (uint256) {
        if (token == dexs) {
            uint256 amount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(bar, amount);
            return 0;
        }
        if (token == weth) {
            uint256 amount = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(factory.getPair(weth, dexs), amount);
            return amount;
        }
        IDEXswapPair pair = IDEXswapPair(factory.getPair(token, weth));
        if (address(pair) == address(0)) {
            return 0;
        }
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        address token0 = pair.token0();
        (uint256 reserveIn, uint256 reserveOut) = token0 == token
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountIn = IERC20(token).balanceOf(address(this));
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        uint256 amountOut = numerator / denominator;
        (uint256 amount0Out, uint256 amount1Out) = token0 == token
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        IERC20(token).transfer(address(pair), amountIn);
        pair.swap(
            amount0Out,
            amount1Out,
            factory.getPair(weth, dexs),
            new bytes(0)
        );
        return amountOut;
    }

    function _toDEXS(uint256 amountIn) internal {
        IDEXswapPair pair = IDEXswapPair(factory.getPair(weth, dexs));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        address token0 = pair.token0();
        (uint256 reserveIn, uint256 reserveOut) = token0 == weth
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        uint256 amountOut = numerator / denominator;
        (uint256 amount0Out, uint256 amount1Out) = token0 == weth
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        pair.swap(amount0Out, amount1Out, bar, new bytes(0));
    }
}
