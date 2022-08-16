// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

//0x0000000000000000000000000000000000000000
//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 1723720445 ,Yiğit
//0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
error This_Parent_Already_Exist();
error InterFi__NotOwner();
error Child__isUnderage();
error Child__Cant_Have_Child_Without_Parents();
error Child__Parent_Not_Found_Add_Parent_First();
error There_is_no_child_belongs_parent();
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
        
        
        if (block.timestamp > releaseTime ) {
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

    
    // get amount of ether from child balance , send to the msg.sender wallet
    function fund(address payable _child) public payable {
         // check the parent exist
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent()");
        
        // check this child belongs to this parent 
        uint size =parent.children.length;
        uint index;
        for (uint i = 0; i < size; i++) {
            if(parent.children[i]==_child){
                index=i;            
            }
        }
        if(index>=0){
            
            Child storage child = addressToChild[_child];                        
            emit Purchase(msg.sender, 1);
            child.amount+=msg.value;
        }
        else{
            
            revert There_is_no_child_belongs_parent();
        }

    }

    receive() external payable {}

    fallback() external payable {}

    event Purchase(
        address indexed _invester,
        uint256 _amount
    );
    
    // parent can get amount of coin from his/her child balance ,msg.sender has to be parent
    function withdrawParent(address payable _child) public payable {
                 

        // check the parent exist
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent()");
        
        // check this child belongs to this parent 
        uint size =parent.children.length;
        uint index;
        for (uint i = 0; i < size; i++) {
            if(parent.children[i]==_child){
                index=i;            
            }
        }
        if(index>=0){
            
            Child storage child = addressToChild[_child];                        
            emit Purchase(msg.sender, 1);
            child.amount-=msg.value;
            parent.Address.transfer(msg.value); // send the amount of value to the parent address 
            
        }
        else{
            
            revert There_is_no_child_belongs_parent();
        }

    }

    //  child can get amount of coin from his/her balance, msg.sender has to be child
     function withdrawChild(address payable _child) public payable {
         
         

     }


}
