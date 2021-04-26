const { expect } = require("chai");

describe("Factory", function () {
  it("create Product And Deposit", async function () {
    const [owner, other] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
    await factory.deployed();

    const Frc758 = await ethers.getContractFactory("ChaingeTestToken");
    const token = await Frc758.deploy("TokenA", "F1", 18);
    await token.deployed();

    console.log('frc758', token.mint)
    await token.mint(owner.address , "1000000000000000000")
    const bal = await token.balanceOf(owner.address); 
    console.log('token balance:', parseInt(bal._hex))

    const productAddress = await factory.create(token.address, 1000, 1613232311, owner.address)
    console.log(1)
    // error 名字不对
    const product = await ethers.getContractAt("Product", productAddress, owner);
    console.log(2)
    product.deposit(owner.address, 1000)
    console.log(3)
    const res = await product.balanceOf(owner.address)
    console.log(res)
    console.log(5)

    // const res = await factory.deposit(owner, 100)
    // console.log('res', res)
    // expect(await greeter.greet()).to.equal("Hello, world!");

    // await greeter.setGreeting("Hola, mundo!");
    expect(1).to.equal(1);
  });
});

