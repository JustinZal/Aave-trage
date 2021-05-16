pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import { ILendingPool } from '@aave/protocol-v2/contracts/interfaces/ILendingPool.sol';
import { DataTypes } from '@aave/protocol-v2/contracts/protocol/libraries/types/DataTypes.sol';
import { IERC20 } from '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import { IUniswapV2Router02 } from '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import { IAToken } from '@aave/protocol-v2/contracts/interfaces/IAToken.sol';

contract AaveTrage {

    address private uniswap;
    address private aave;

    constructor (address _uniswapAddress, address _aaveAddress) public {
        uniswap = _uniswapAddress;
        aave = _aaveAddress;
    }

    /*
        Function peek - Returns the best tokens to borrow and supply for arbitrage
        Returns: tuple of addresses bestBorrowToken, bestSupplyToken
    */
    function peek() external returns (address bestBorrowToken, address bestSupplyToken) {
        address[] memory reserves = ILendingPool(aave).getReservesList();
        uint128 maxLend = 1;
        uint128 minBorrow = uint128(-1);

        for (uint i = 0; i < reserves.length; i++) {
            DataTypes.ReserveData memory reserveData = ILendingPool(aave).getReserveData(reserves[i]);
            uint128 borrowAPY = reserveData.currentVariableBorrowRate;
            uint128 depositAPY = reserveData.currentLiquidityRate;

            if (borrowAPY < minBorrow && borrowAPY > 0) {
                minBorrow = borrowAPY;
                bestBorrowToken = reserves[i];
            }

            if (depositAPY > maxLend) {
                maxLend = depositAPY;
                bestSupplyToken = reserves[i];
            }
        }
    }

    function guap(address collateral, uint256 amount, address borrowedAsset, uint256 amountToBorrow, address arbitrageAsset) external {
        _deposit(collateral, amount);
        _borrow(borrowedAsset, amountToBorrow);

        uint256 borrowedBalance = IERC20(borrowedAsset).balanceOf(address(this));
        _swap(borrowedAsset, arbitrageAsset, borrowedBalance);

        uint256 arbitrageBalance = IERC20(arbitrageAsset).balanceOf(address(this));
        _deposit(arbitrageAsset, arbitrageBalance);
    }

    function shut(address arbitrageAsset, address borrowedAsset, address collateral, uint256 withdrawAmount) external {
        _withdraw(arbitrageAsset, type(uint).max);

        uint256 arbitrageBalance = IERC20(arbitrageAsset).balanceOf(address(this));
        _swap(arbitrageAsset, borrowedAsset, arbitrageBalance);

        uint256 borrowedBalance = IERC20(borrowedAsset).balanceOf(address(this));
        uint256 payback = _repay(borrowedAsset, borrowedBalance);

        _withdraw(collateral, withdrawAmount);
        IERC20(collateral).transfer(msg.sender, withdrawAmount);
    }

    function _repay(address asset, uint256 amount) internal returns (uint256 payback) {
        IERC20(asset).approve(aave, amount);
        payback = ILendingPool(aave).repay(asset, amount, 2, address(this));
    }

    function _withdraw(address asset, uint256 amount) internal {
        ILendingPool(aave).withdraw(asset, amount, address(this));
    }

    function _deposit(address collateral, uint256 amount) internal {
        IERC20(collateral).approve(aave, amount);
        ILendingPool(aave).deposit(collateral, amount, address(this), 0);
    }

    function _borrow(address assetToBorrow, uint256 amount) internal {
        ILendingPool(aave).borrow(assetToBorrow, amount, 2, 0, address(this));
    }

    function _swap(address from, address to, uint256 amount) internal returns (uint256 balance) {
        IERC20(from).approve(uniswap, amount);
        address[] memory path = new address[](2);
        path[0] = from;
        path[1] = to;
        IUniswapV2Router02(uniswap).swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp + 10 ** 2);
    }
}