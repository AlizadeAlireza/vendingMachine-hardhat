// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

// for test

/*  custom errors  */

error VendingMachine__ownerProperties(address owner);
error VendingMachine__payMoreEth(uint amount);
error VendingMachine__NotEnoughDonut(uint remainDonut);

contract VendingMachine {
    /*  variables  */
    address public owner;

    mapping(address => uint256) public donutBalances;

    constructor() {
        owner = msg.sender;
        donutBalances[address(this)] = 100;
    }

    // anyone should be able to set amount of donut
    // getting total balance

    modifier ownerProperties(address _user) {
        if (_user != owner) {
            revert VendingMachine__ownerProperties(owner);
        }
        _;
    }

    // because update the value --> don't use the view or pure
    function restock(uint256 _amount) public ownerProperties(msg.sender) {
        donutBalances[address(this)] += _amount;
    }

    // payable for receive ether
    function purchase(uint256 _amount) public payable {
        // we need to check purchaser send enough money

        if (msg.value < _amount * 2 ether) {
            revert VendingMachine__payMoreEth(_amount * 2 ether);
        }
        // enough donuts in the vending machine for requests

        if (donutBalances[address(this)] < _amount) {
            revert VendingMachine__NotEnoughDonut(donutBalances[address(this)]);
        }

        donutBalances[address(this)] -= _amount;
        donutBalances[msg.sender] += _amount;
    }

    /*  getter functions  */

    function getVendingMachineBalance() public view returns (uint256) {
        return donutBalances[address(this)];
    }

    function getBuyerBalancer() public view returns (uint256) {
        return donutBalances[msg.sender];
    }
}

// for this smart contract
// i can refactore some functions

// like this function
// for checking the vending machine stocks we can use it, if i can do it we can skip it

// for not enough donate i can use it, it can be very good.
