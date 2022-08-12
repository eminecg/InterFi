// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";


error InterFi__NotOwner();
error Child__isUnderage();
error Child__Cant_Have_Child_Without_Parents();
error Child__Parent_Not_Found_Add_Parent_First();

contract Interfi{

    address public owner;
    bool isUnderage = true;

    struct Parent {
        address parentAddress;
        address[]  children;
        string name;
    }

    struct Child {
        address childAddress;
        uint birthday;
        address[] parents;
        string name;
    }

    uint parentCount= 0;
    uint childCount= 0;

    mapping(address => Child) public addressToChild;
    mapping(address => Parent) public addressToParent;

   
    mapping(address => address[]) public parentAddressToChilds;
    mapping(address => uint256) public balances;

    modifier onlyOwner (){
    if (msg.sender != owner)
        {revert InterFi__NotOwner();}
        _;
    }

    uint counter = 0;


       address[]  childrens ;
      function addParent(address payable _parent, string memory _name) public {  
           
        

            addressToParent[_parent] = Parent({parentAddress:_parent,children:childrens,name:_name});
            
        } 

        address[]  parents ;
        function addChild(address payable _parent,address payable _child, uint256 _birthday ,address payable _otherParent, string memory _name) public {  
           
         parents.push(_parent);
         parents.push(_otherParent);

            addressToChild[_child] = Child({childAddress:_child,birthday:_birthday,parents:parents,name:_name});
            addressToParent[_parent].children.push(_child);

        }

        function getBalance() public view returns (uint256) {
            return address(this).balance;
        }
    
        function ageCalc(uint256 birthdayInSec) public returns (uint256) {
            uint256 ageInSec = (block.timestamp - birthdayInSec);
            if ((ageInSec / 31536000) >= 18) {
                isUnderage = false;
            } else {
                isUnderage = true;
            }
            return (ageInSec / 31536000); // year in seconds
        }
    
    
        function getChild(uint256 index) public view returns (address) {
        }
    
        function fund() public payable {
        }
    
        // burası çalışmıyor ??
        function withdraw() public payable {
            if (isUnderage) {
                revert Child__isUnderage();
            } else {}
        }
    
        receive() external payable {
            fund();
        }
    
        fallback() external payable {
            fund();
        }
    }

    