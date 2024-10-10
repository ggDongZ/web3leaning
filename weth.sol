// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract WETH {

    string public name = "Wrapped Wther";

    string public symbol = "WETH";

    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed delegateAds, uint256 amount);

    event Transfer(address indexed src, address indexed toAds, uint256 amount);

    event Deposit(address indexed toAds, uint256 amount);

    event Withdraw(address indexed src, uint256 amouny);

    mapping(address => uint256) public balanceof;

    mapping(address => mapping(address => uint256)) public allowance;

    function dePosit() public payable {
        balanceof[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        require(balanceof[msg.sender] >= amount);
        balanceof[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function totalSupply() public view returns(uint256) {
        return address(this).balance;
    }

    function approve(address delegateAds, uint256 amount) public returns(bool) {
        require(balanceof[msg.sender] >= amount);
        allowance[msg.sender][delegateAds] += amount;

        emit Approval(msg.sender, delegateAds, amount);

        return true;
    }

    function transfer(address toAds, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, toAds, amount);
    }

    function transferFrom(address src, address toAds, uint256 amount) public returns (bool) {
        require(balanceof[src] >= amount);

        if(src != msg.sender){
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        balanceof[src] -= amount;
        balanceof[toAds] += amount;

        emit Transfer(src, toAds, amount);
        return true;
    }

    fallback() external payable { 
        dePosit();
    }

    receive() external payable { 
        dePosit();
    }



    

    
}
