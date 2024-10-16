// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MultiSignWallet {

    //钱包拥有者
    address[] public owners;

    //需要同意事务的拥有者个数
    uint256 public required;

    //定义map用于快速查询指定地址是否为钱包拥有者
    mapping(address => bool) public isOwner;

    //转账事务
    struct Transaction{
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    //事务数组
    Transaction[] public transactions;

    //定义map保存事务被哪些拥有者同意
    mapping(uint256 => mapping(address => bool)) public approved;

    //事件
    event Deposit(address indexed sender, uint amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint indexed txId);

    receive() external payable { 
        emit Deposit(msg.sender, msg.value);
    }

    //只能钱包拥有者可以操作
    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }

    //判断事务是否存在
    modifier txExists(uint256 _txId){
        require(_txId < transactions.length, "transaction not exist");
        _;
    }

    //事务应没有同意
    modifier notApprove(uint256 _txId){
        require(!approved[_txId][msg.sender], "already approve");
        _;
    }

    //事务应还没有执行
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    //构造方法
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners length need > 0");
        require(_required > 0 && _required <= _owners.length, "invalid number of required");
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not uinque");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    //获取合约余额
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    //提交事务
    function submit(address _to, uint256 _amount, bytes calldata _data) external onlyOwner returns (uint256) {
        transactions.push(Transaction({
            to:_to,
            value:_amount,
            data:_data,
            executed:false
        }));
        
        emit Submit(transactions.length - 1);
        return transactions.length-1;
    }

    //同意事务
    function approve(uint256 _txId) external onlyOwner notApprove(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    //执行事务
    function execute(uint256 _txId) external onlyOwner notExecuted(_txId) {
        require(getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction  = transactions[_txId];
        transaction .executed = true;
        (bool success, ) = transaction .to.call{value:transaction .value}(transaction .data);
        require(success, "execute failed");
        emit Execute(_txId);
    }

    //获取指定事务同意的人数
    function getApprovalCount(uint _txId) public view returns(uint256 count) {
        for (uint256 index = 0; index < owners.length; index++) 
        {
            address owner = owners[index];
            if(approved[_txId][owner]){
                count++;
            }
        }
    }

    //取消事务同意
    function revoke(uint256 _txId) external onlyOwner notExecuted(_txId) txExists(_txId) {
        require(approved[_txId][msg.sender], "tx is not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    
}
