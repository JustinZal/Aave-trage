const HDWalletProvider = require("truffle-hdwallet-provider");
require('dotenv').config();

const {
  DEPLOYMENT_PRIVATE_KEY_KOVAN,
  KOVAN_INFURA_URL
} = process.env;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    kovan: {
      provider: () => new HDWalletProvider(DEPLOYMENT_PRIVATE_KEY_KOVAN, KOVAN_INFURA_URL),
      network_id: '42'
    }
  },
  mocha: {
    timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.6.12",
      docker: true,
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "byzantium"
      }
    }
  },
  db: {
    enabled: false
  }
};
