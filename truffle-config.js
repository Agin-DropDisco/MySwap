const HDWalletProvider = require('truffle-hdwallet-provider')
const { readFileSync } = require('fs')
const path = require('path')
const Matic = require ("@maticnetwork/maticjs");
const dotenv = require('dotenv');
dotenv.config();

const mnemonic = process.env.MNEMONIC;
const privateKey = process.env.PRIVATE_KEY;
console.log(`MNEMONIC: ${process.env.MNEMONIC}`)
console.log(`INFURA_API_KEY: ${process.env.INFURA_API_KEY}`)
console.log(`INFURA_API_KEY: ${process.env.PRIVATE_KEY}`)

module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    ganache: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
    },
    rinkeby: {
      provider: () => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`, 0, 10),
      network_id: 4,
      gas: 5000000,
      gasPrice: 25000000000,
      skipDryRun: true
    },
    moonalpha: {	
      provider: () => new HDWalletProvider([privateKey], "https://rpc.testnet.moonbeam.network"),
      network_id: 1287,	
      gas: 0,	
      gasPrice: 10000000000 //10 Gwei	
    },	
    oasis: {	
      provider: () => new HDWalletProvider([privateKey], "https://rpc.oasiseth.org:8545"),
      network_id: 69,	
      gas: 9000000,	
      gasPrice: 1000000000 //1 Gwei	
    },	
    matic: {	
      provider: () => new HDWalletProvider(mnemonic, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      gas: 0,	
      confirmations: 2,
      timeoutBlocks: 200,
      blockGasLimit: 20000000,
      gasPrice: 1000000000,
      skipDryRun: true
    },
  },

  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  },
  compilers: {
    solc: {
      version: "0.6.6"
    }
  }
};
