// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

//0x0000000000000000000000000000000000000000
//0x302955b74C969aA09bb270DAa775B65Fc9b7Bc29
// 0x302955b74C969aA09bb270DAa775B65Fc9b7Bc29, 1723720445 ,Yiğit
error This_Parent_Already_Exist();
error InterFi__NotOwner();
error Child__isUnderage();
error Child__Cant_Have_Child_Without_Parents();
error Child__Parent_Not_Found_Add_Parent_First();

contract Interfi {
    address private owner;

    struct Parent {
        address payable Address;
        address[] children;
        string name;
    }

    struct Child {
        address payable Address;
        address payable invester;
        uint256 releaseTime;
        uint256 amount;
        bool isRelasable;
        string name;
    }

    mapping(address => Child) public addressToChild;
    mapping(address => Parent) public addressToParent;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert InterFi__NotOwner();
        }
        _;
    }

    function addParent(string memory _name) public {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address == address(0), "This_Parent_Already_Exist");

        parent.name = _name;
        parent.Address = payable(msg.sender);
    }

    function addChild(
        address payable _child,
        uint256 _releaseTime,
        string memory _name
    ) public {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent()");

        Child storage child = addressToChild[_child];
        require(child.Address == address(0), "This_Child_Already_Exist()");

        child.Address = _child;
        child.releaseTime = _releaseTime;
        child.amount = 0;
        child.invester = payable(msg.sender);
        child.name = _name;

        parent.children.push(_child);
    }

    function ageCalc(address payable _child) public returns (bool) {
        console.log(block.timestamp);
        Child storage child = addressToChild[_child];
        uint256 releaseTime = child.releaseTime;
        console.log(releaseTime);
        uint256 ageCheck = (block.timestamp - releaseTime);
        console.log(ageCheck);
        if (block.timestamp - releaseTime > 0) {
            child.isRelasable = true;
        } else {
            child.isRelasable = false;
        }
        return child.isRelasable;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getChildren() public view returns (address[] memory) {
        return addressToParent[msg.sender].children;
    }

    function fund() public payable {}

    function withdraw() public payable {}

    receive() external payable {}

    fallback() external payable {}
}
