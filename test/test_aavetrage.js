const AaveTrage = artifacts.require('AaveTrage');
const uniswap = require('@uniswap/v2-periphery/build/UniswapV2Router02.json');
const aave = require('@aave/protocol-v2/artifacts/contracts/protocol/lendingpool/LendingPool.sol/LendingPool.json');
const _ = require('lodash')

//MAIN NETWORK
const UNISWAP_ADDRESS = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D';
const AAVE_ADDRESS = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9';

contract('Aave-Trage', accounts => {
    const user1 = accounts[0];
    const user2 = accounts[1];
    let UNISWAP;
    let AAVE;
    let AAVETRAGE;

    beforeEach(async () => {
        UNISWAP = new web3.eth.Contract(uniswap.abi, UNISWAP_ADDRESS);
        AAVE = new web3.eth.Contract(aave.abi, AAVE_ADDRESS);
        AAVETRAGE = await AaveTrage.new(UNISWAP_ADDRESS, AAVE_ADDRESS);
    })

    it('Should perform peek correctly', async () => {
        const { bestBorrowToken, bestSupplyToken } = await AAVETRAGE.peek.call();

        const reserves = await AAVE.methods.getReservesList().call();
        const reservesInfo = await Promise.all(reserves.map(address => AAVE.methods.getReserveData(address).call()));
        let borrowManual;
        let supplyManual;
        let supplyMax = -Infinity;
        let borrowMin = Infinity;

        for (i = 0; i < reserves.length; i++) {
            const borrowAPY = Number(reservesInfo[i]['currentVariableBorrowRate']);
            const supplyAPR = Number(reservesInfo[i]['currentLiquidityRate']);

            if (borrowAPY < borrowMin && borrowAPY > 0) {
                borrowMin = borrowAPY;
                borrowManual = reserves[i];
            }

            if (supplyAPR > supplyMax) {
                supplyMax = supplyAPR;
                supplyManual = reserves[i];
            }
        }

        assert.equal(bestBorrowToken.toLowerCase(), borrowManual.toLowerCase(), 'Borrow tokens mismatch!');
        assert.equal(bestSupplyToken.toLowerCase(), supplyManual.toLowerCase(), 'Supply tokens mismatch!');
    });
});
