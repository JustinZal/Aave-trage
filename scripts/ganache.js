const ganache = require("ganache-core");
require('dotenv').config();

const server = ganache.server({ fork: process.env.MAINNET_INFURA_URL, gasLimit: 12.5e6, gasPrice: 1e6, unlocked_accounts: [0, 1], logger: console });
server.listen(8545);
