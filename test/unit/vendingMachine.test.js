const { expect } = require("chai");
const { ethers } = require ("hardhat");

describe("VendingMachine", function () {
  let owner;
  let user;
  let vendingMachine;
  const INITIAL_BALANCE = 100;
  const DONUT_PRICE = 2;
  const PURCHASED_DONUTS = 5;

  beforeEach(async function () {
    // deploy a new instance of VendingMachine
    [owner, user] = await ethers.getSigners();
    const VendingMachine = await ethers.getContractFactory("VendingMachine");
    vendingMachine = await VendingMachine.deploy();
    await vendingMachine.deployed();
  });

  it("should have an initial balance of 100 donuts", async function () {
    const balance = await vendingMachine.getVendingMachineBalance();
    expect(balance).to.equal(INITIAL_BALANCE);
  });

  it("should allow the owner to restock the vending machine", async function () {
    const restockAmount = 50;
    await vendingMachine.restock(restockAmount);
    const balance = await vendingMachine.getVendingMachineBalance();
    expect(balance).to.equal(INITIAL_BALANCE + restockAmount);
  });

  it("should allow a user to purchase donuts", async function () {
    const value = ethers.utils.parseEther((PURCHASED_DONUTS * DONUT_PRICE).toString());
    await vendingMachine.purchase(PURCHASED_DONUTS, { value });
    const balance = await vendingMachine.getVendingMachineBalance();
    expect(balance).to.equal(INITIAL_BALANCE - PURCHASED_DONUTS);

    const userBalance = await vendingMachine.donutBalances(owner.address);
    expect(userBalance).to.equal(PURCHASED_DONUTS);
  });

  it("should not allow a purchase if the user sends insufficient funds", async function () {
    const value = ethers.utils.parseEther((PURCHASED_DONUTS * DONUT_PRICE - 1).toString());
    await expect(vendingMachine.purchase(PURCHASED_DONUTS, { value })).to.be.revertedWith("You must pay at least 2 Ether per donut");
  });

  it("should not allow a purchase if there are not enough donuts in stock", async function () {
    const value = ethers.utils.parseEther((PURCHASED_DONUTS * DONUT_PRICE + 200).toString());
    await expect(vendingMachine.purchase(INITIAL_BALANCE + 1, { value })).to.be.revertedWith("Not enough donut in stock to fulfill purchase request");
  });

  it("should not allow a user instead owner to restock the balance", async() => {
    await expect(vendingMachine.connect(user).restock(10)).to.be.revertedWith("only the owner can restock this machine.");
   })
});