// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract VendingMachine {
    address public owner;
    mapping(address => uint256) public donutBalances;

    constructor() {
        owner = msg.sender;
        donutBalances[address(this)] = 100;
    }

    // anyone should be able to set amount of donut
    // getting total balance
    function getVendingMachineBalance() public view returns (uint256) {
        return donutBalances[address(this)];
    }

    function getBuyerBalancer() public view returns (uint256) {
        return donutBalances[msg.sender];
    }

    // because update the value --> don't use the view or pure
    function restock(uint256 _amount) public {
        require(
            msg.sender == owner,
            "only the owner can restock this machine."
        );
        donutBalances[address(this)] += _amount;
    }

    // payable for receive ether
    function purchase(uint256 _amount) public payable {
        // we need to check purchaser send enough money
        require(
            msg.value >= _amount * 2 ether,
            "You must pay at least 2 Ether per donut"
        );
        // enough donuts in the vending machine for requests
        require(
            donutBalances[address(this)] >= _amount,
            "Not enough donut in stock to fulfill purchase request"
        );

        donutBalances[address(this)] -= _amount;
        donutBalances[msg.sender] += _amount;
    }
}
