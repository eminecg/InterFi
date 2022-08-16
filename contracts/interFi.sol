// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
/*
0x0000000000000000000000000000000000000000
 parent 
0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
  child 1
0x617F2E2fD72FD9D5503197092aC168c91465E7f2, 1723720445 ,X
0x617F2E2fD72FD9D5503197092aC168c91465E7f2
  child 2
0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 1723720445 ,Y
0x17F6AD8Ef982297579C203069C1DbfFE4348c372
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
*/

error This_Parent_Already_Exist();
error InterFi__NotOwner();
error Child__isUnderage();
error Child__Cant_Have_Child_Without_Parents();
error Child__Parent_Not_Found_Add_Parent_First();
error There_is_no_child_belongs_parent();
error There_is_no_enough_child_balance_to_draw();
error Role_is_not_valid();
error  Not_released_yet();
error There_is_no_user();

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
        bool isReleasable;
        string name;
    }

    mapping(address => Child) private addressToChild;
    mapping(address => Parent) private addressToParent;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert InterFi__NotOwner();
        }
        _;
    }
    modifier onlyisReleaseState(){
        bool state = ageCalc(payable(msg.sender));
        if(state== false){
            revert Not_released_yet();
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
            child.isReleasable = true;
        } else {
            child.isReleasable = false;
        }
        return child.isReleasable;
    }

    // Getter Functions 

    // returns total balance of contract
    function getBalance() public view returns (uint256) {                                           // not tested
        return address(this).balance;
    }

    // returns given child  address amount                                                          // not tested
    function getAmount(address payable _child) public view returns (uint256) {

        Child storage child = addressToChild[_child];
        return child.amount;
    }

    function getChildren() public view returns (address[] memory) {
        return addressToParent[msg.sender].children;
    }

    // returns role of sender address
    function getRole() public view returns(string memory) {                                           
       
        Parent storage parent = addressToParent[msg.sender];
        Child storage child = addressToChild[msg.sender];
        
        if( (parent.Address!= address(0))  ){
            return "Parent";
        }
        else if(child.Address != address(0)) {
            return "Child";
        }
        else{
            return "Unregister ";
        }       
    }
    
    // get parent struct 
    function getParent()  public view returns(Parent memory) {                                               
            Parent storage parent = addressToParent[msg.sender];
            if( (parent.Address!= address(0))  ){
                return parent;  
            }
            else{
                revert There_is_no_user(); 
            }       
    }

     // get child struct 
    function getChild()  public view returns(Child memory) {                                               
           
            Child storage child = addressToChild[msg.sender];
            if( (child.Address!= address(0))  ){
                return child;  
            }
            else{
                revert There_is_no_user(); 
            }
                
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
    function withdrawParent(address payable _child, uint _amount) public payable {
                 

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
            child.amount-=_amount;
            payable(msg.sender).transfer(_amount); // send the amount of value to the parent address 
            
        }
        else{
            
            revert There_is_no_child_belongs_parent();
        }

    }

    //  child can get amount of coin from his/her balance, msg.sender has to be child
     function withdrawChild(address payable _child,uint _amount) public payable onlyisReleaseState {
      
        // check the child exist
        Child storage child = addressToChild[_child];     
        require(child.Address != address(0), "There_Is_No_Such_Child()");  

        
        if(child.amount>=_amount){
            
                               
            emit Purchase(msg.sender, 1);
            child.amount-=_amount;
            payable(msg.sender).transfer(_amount); // send the amount of value to the parent address 
            
        }
        else{
            
            revert There_is_no_enough_child_balance_to_draw();
        }        


     }

    
}


/*

    // for string comparison 
     function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    } 

*/