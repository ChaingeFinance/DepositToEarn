const { expect } = require("chai");

describe("Factory", function() {
  it("create Product And Deposit", async function() {
    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy();
    
    await factory.deployed();

    factory.create('', 1000, 1613232311)

    // expect(await greeter.greet()).to.equal("Hello, world!");

    // await greeter.setGreeting("Hola, mundo!");
    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});

