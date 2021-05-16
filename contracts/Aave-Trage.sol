pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import { ILendingPool } from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import { DataTypes } from '@aave/protocol-v2/contracts/protocol/libraries/types/DataTypes.sol';


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


}