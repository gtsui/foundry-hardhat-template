import '@nomicfoundation/hardhat-ethers';
import '@nomicfoundation/hardhat-verify';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'dotenv/config';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {

  solidity: {
    version: "0.8.17",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    ethereum: {
      url: process.env.ETHEREUM_PROVIDER,
      chainId: 1,
      accounts: process.env.KEYS_PROD!.split(","),
      timeout: 120000000,
      zksync: false
    },
    goerli: {
      url: process.env.GOERLI_PROVIDER,
      chainId: 5,
      accounts: process.env.KEYS_DEV!.split(","),
      timeout: 120000000,
      zksync: false
    }
  },
  
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_APIKEY,
      goerli: process.env.ETHERSCAN_APIKEY
    }
  },

  defender: {
    apiKey: process.env.DEFENDER_TEAM_API_KEY,
    apiSecret: process.env.DEFENDER_TEAM_API_SECRET_KEY,
  }
  
}
