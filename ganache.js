const ganache = require("ganache-core");
require('dotenv').config();
const server = ganache.server({ fork: 'https://mainnet.infura.io/v3/37083cdb583d4ad89173a835bdb34a8c', gasLimit: 12.5e6, gasPrice: 1e6, unlocked_accounts: [0, 1], logger: console });
server.listen(8545);