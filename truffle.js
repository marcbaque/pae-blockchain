module.exports = {
  networks: {
    development: {
      host: "localhost",
      gas: 4600000,
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8545,
	  gas: 2100000, 
      network_id: 3 // Match any network id
    },
	rpc: {
	  host: 'localhost',
	  post: 8080,
	  network_id: 45789922
	}
  }
  
};
