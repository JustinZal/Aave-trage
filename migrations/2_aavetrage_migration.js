const AaveTrage = artifacts.require("AaveTrage");
require('dotenv').config();

const { KOVAN_AAVE_ADDRESS, KOVAN_UNISWAP_ADDRESS } = process.env;

module.exports = function (deployer) {
    deployer.deploy(AaveTrage, KOVAN_UNISWAP_ADDRESS, KOVAN_AAVE_ADDRESS);
};
