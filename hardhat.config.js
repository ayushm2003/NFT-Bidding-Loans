// Imports
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
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
};
