import 'dotenv/config';
import 'hardhat-deploy';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@openzeppelin/hardhat-upgrades';
import '@openzeppelin/hardhat-defender';
import 'hardhat-gas-reporter';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {

  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    ethereum: {
      url: process.env.ETHEREUM,
      chainId: 1,
      accounts: process.env.ETHEREUM_KEYS!.split(","),
      timeout: 120000000,
      verify: {
        etherscan: {
          apiUrl: "http://etherscan.io",
          apiKey: process.env.ETHERSCAN_APIKEY
        }
      }
    }
  },

  mocha: {
    timeout: 12000000
  },

  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_APIKEY
    }
  },
  
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_APIKEY,
      goerli: process.env.ETHERSCAN_APIKEY,
    }
  },

  gasReporter: {
    enabled: true,
    fast: true,
    gasPrice: 100,
    coinmarketcap: process.env.COINMARKETCAP_APIKEY,    
    currency: 'USD',
    noColors: true,
    excludeContracts: ['test/']
  },
  
  defender: {
    apiKey: process.env.DEFENDER_TEAM_API_KEY,
    apiSecret: process.env.DEFENDER_TEAM_API_SECRET_KEY,
  }
  
}
