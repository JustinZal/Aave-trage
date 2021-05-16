pragma solidity 0.6.12;

import { ILendingPool } from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";

contract AveaTrage {

    function peek(address memory assetAddress) {
        return ILendingPool.getReserveData(assetAddress);
    }

}