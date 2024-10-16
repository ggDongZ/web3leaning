// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherWallet {

    address payable public immutable owner;

    event Log(string funName, address from, uint256 value, bytes date);

    constructor()  {
        owner = payable(msg.sender);
    }

    receive() external payable { 
        emit Log("receive", msg.sender, msg.value, "");
    }

    function withDraw1() external  {
        require(owner == msg.sender, "not owner");
        payable(msg.sender).transfer(100);
    }

    function withDraw2() external {
        require(owner == msg.sender, "not owner");
        bool success = payable(msg.sender).send(100);
        require(success, "pay faild");
    }

    function withDraw3() external {
        require(owner == msg.sender, "not owner");
        (bool success,)=msg.sender.call{value:address(this).balance}("");
        require(success, "pay faild");
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
    
}
