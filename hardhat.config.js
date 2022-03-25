require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const PRIVATE_KEY ="0ba109ca631a1a7bc8aa79ea8c7a398e8a12d262632711087a478d2b843"
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // accounts: [{
      //   privateKey: PRIVATE_KEY,
      //   balance: String(10*1000000000000000000)
      // }]
    },
    // rinkeby: {
    //   url: "https://rinkeby.infura.io/v3/985b91f68c354499a922a0aa99bbd076",
    //   accounts: [`0x${PRIVATE_KEY}`]
    // }
  },
  solidity: "0.8.4"
};
