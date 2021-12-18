module.exports = {
  networks: {

    // rinkeby: ローカルノードへのRPC接続
    rinkeby_rpc: {
      host: "localhost",
      port: 8545,
      network_id: 4,
      gas: 5000000,           // 5 m
      gasPrice: 10000000000   // 10 gwei
    }
    
  },

  //--------------------------------
  // compile settings
  //--------------------------------
  compilers: {
    solc: {
      version: "0.8.7",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
}
