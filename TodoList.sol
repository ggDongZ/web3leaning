// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Demo {

    struct TODO{
        string name;
        bool isCompleted;
    }

    TODO[] public list;


    function create(string memory _name) external {
        list.push(TODO({
            name:_name,
            isCompleted:false
        }));
    }

    function modiName1(uint256 index, string memory _name) external  {
        list[index].name = _name;
    }

    function modiName2(uint256 index, string memory _name) external {
        TODO storage todo = list[index];
        todo.name = _name;
    }

    function modiStatus1(uint256 index, bool _status) external  {
        list[index].isCompleted = _status;
    }

    function modiStatus2(uint256 index) external {
        list[index].isCompleted = !list[index].isCompleted;
    }

    function get1(uint256 index) external view returns (string memory name, bool isCompleted) {
        return (list[index].name, list[index].isCompleted);
    }

    function get2(uint256 index) external view returns(string memory name, bool isCompleted) {
        TODO storage todo = list[index];
        return(todo.name,todo.isCompleted);
    }



    
}
