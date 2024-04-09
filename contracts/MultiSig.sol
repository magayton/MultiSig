// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiSig {
    address[] public owners;
    uint public required;

    struct Transaction {
        address destination;
        uint amount;
        bool executed;
        bytes data;
    }

    mapping(uint => Transaction) public transactions;
    uint public transactionCount;

    mapping(uint => mapping(address => bool)) public confirmations;

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0);
        require(_required > 0);
        require(_required <= _owners.length);

        owners = _owners;
        required = _required;
    }

    function addTransaction(address destination, uint amount, bytes memory data) internal returns(uint) {
        uint transactionId = transactionCount;
        transactions[transactionCount] = Transaction(destination, amount, false, data);
        transactionCount += 1;

        return transactionId;
    }

    function confirmTransaction(uint id) public onlyOwners{
        confirmations[id][msg.sender] = true;
        if(isConfirmed(id)) {
            executeTransaction(id);
        }
    }

    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint totalConfirmations;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                totalConfirmations += 1;
            }
        }

        return totalConfirmations;
    }

    modifier onlyOwners {
        bool isOwner = false;
        for(uint i = 0; i < owners.length; i++) {
            if(msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner);
        _;
    }

    function submitTransaction(address destination, uint value, bytes memory data) external {
        uint id = addTransaction(destination, value, data);
        confirmTransaction(id);
    }

    receive() external payable {
        
    }

    function isConfirmed(uint id) public view returns(bool) {
        return getConfirmationsCount(id) >= required;
    }

    function executeTransaction(uint id) public {
        require(isConfirmed(id));
        Transaction storage transac = transactions[id];
        (bool success, ) = transac.destination.call{value:transac.amount}(transac.data);
        require(success);
        transactions[id].executed = true;
    }
}
