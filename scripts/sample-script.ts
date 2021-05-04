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
  
  const [owner, other] = await hre.ethers.getSigners();

  // We get the contract to deploy
  const Product = await hre.ethers.getContractFactory("Product");

  const MyToken = await hre.ethers.getContractFactory("MyToken");

  const exampleToken = await MyToken.deploy("Hello", "World", 18, "90000000000000000000000000");
  await exampleToken.deployed();


  const chng = await MyToken.deploy("Hello", "World", 18, "90000000000000000000000000");
  await chng.deployed();

  async function sleep() {
    return new Promise<void>(function(resv) {
        setTimeout(() => {
          resv()
        }, 10000)
    })
  }
  
const amount = '10000000000000000000000000000000000000'
  
console.log('address:', owner.address);
await exampleToken.mint(owner.address, amount);

// await exampleToken.mint(owner.address, amount);

  await sleep()
  
  const product = await Product.deploy(exampleToken.address, "317380671044747", "1651730400", owner.address, "160000000000000000", '0x3ed8997bace69bfe5b729997518b70d342b4c7a5', '0xdf1FAcbC27E16F2189E35eb652564502e75Ebf77');

  await product.deployed();

  await sleep()

  console.log("mytoken deployed to:", exampleToken.address);
  console.log("product deployed to:", product.address);


  await exampleToken.approve(product.address, 1);
  console.log("approve success!");
  await sleep()

  await product.deposit(owner.address, 1)


  /*
  
token:0xef3f3d15fee12926bddb4f90518352f8f8279d3e
rate:2064418317468330
depositEndTime:1640966399
cashbox:0x2a65e249320f413bcb3f2ea21fcfe9e8b30beafd
_rewardRate:160000000000000000
_rewardToken:0x3ed8997bace69bfe5b729997518b70d342b4c7a5
owner:0xdf1FAcbC27E16F2189E35eb652564502e75Ebf77
  */




  // 调用现有合约

  // const product = await hre.ethers.getContractAt("Product", '0x172076E0166D1F9Cc711C77Adf8488051744980C', owner);
  
  // await product.deposit(owner.address, 1);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
