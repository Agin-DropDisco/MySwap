pragma solidity =0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract DEXswapBar is ERC20("DEXswapBar", "xDEXS") {
    using SafeMath for uint256;
    IERC20 public dexs;

    constructor(IERC20 _dexs) public {
        dexs = _dexs;
    }

    // Enter the bar. Pay some DEXSs. Earn some shares.
    function enter(uint256 _amount) public {
        uint256 totalDEXswap = dexs.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalDEXswap == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 what = _amount.mul(totalShares).div(totalDEXswap);
            _mint(msg.sender, what);
        }
        dexs.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your DEXSs.
    function leave(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what = _share.mul(dexs.balanceOf(address(this))).div(
            totalShares
        );
        _burn(msg.sender, _share);
        dexs.transfer(msg.sender, what);
    }
}
