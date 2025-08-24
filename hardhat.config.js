require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {}
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    gasPrice: 0.1, // Arbitrum gas price
    coinmarketcap: process.env.COINMARKETCAP_API_KEY
  }
};
