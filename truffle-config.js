module.exports = {
  networks: {

     development: {
      host: "127.0.0.1", //"10.0.8.24", //"192.168.1.77",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
     },
     develop: {
       port: 8545
     }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.4",    
    }
  }
};
