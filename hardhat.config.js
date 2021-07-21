// Imports
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const dotenv = require("dotenv");

dotenv.config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    rinkeby: {
        url: process.env.RINKEBY_JSONRPC_HTTP_URL,
        accounts: [process.env.WALLET_PRIVATE_KEY_1],
      }
  },
  etherscan: {
      apiKey: process.env.ETHERSCAN_KEY
  }
};
