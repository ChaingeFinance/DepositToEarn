// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Factory = await hre.ethers.getContractFactory("Product");
  
  const factory = await Factory.deploy('0x86469a2612453c270562eef67c9be54216148671', 111212121212121, 777777777, '0x86469a2612453c270562eef67c9be54216148671', 99988877, '0x86469a2612453c270562eef67c9be54216148671', '0x76ee3eeb7f5b708791a805cca590aead4777d378');

  await factory.deployed();

  console.log("Greeter deployed to:", factory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
