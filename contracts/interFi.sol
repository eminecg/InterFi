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

error NotOwner();
error There_is_no_child_belongs_parent();
error There_is_no_enough_child_balance_to_draw();
error Role_is_not_valid();
error Not_released_yet();
error There_is_no_user();
error Not_Enough_Funds();

contract InterFi {
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

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {        
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    modifier onlyisReleaseState() {
        bool state = ageCalc(payable(msg.sender));
        if (state == false) {
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
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

        Child storage child = addressToChild[_child];
        require(child.Address == address(0), "This_Child_Already_Exist");

        child.Address = _child;
        child.releaseTime = _releaseTime;
        child.amount = 0;
        child.invester = payable(msg.sender);
        child.name = _name;
        parent.children.push(_child);
    }

    function ageCalc(address payable _child) public view returns (bool) {
        console.log(block.timestamp);
        Child storage child = addressToChild[_child];
        uint256 releaseTime = child.releaseTime;
        console.log(releaseTime);

        if (block.timestamp > releaseTime) {
            return true;
        } else {
            return false;
        }
    }

    // Getter Functions
    function getOwner() public view returns (address) {
        return owner;
    }

    // returns total balance of contract
    function getBalance() public view onlyOwner returns (uint256) {
        // not tested
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
    function getRole() public view returns (string memory) {
        Parent storage parent = addressToParent[msg.sender];
        Child storage child = addressToChild[msg.sender];

        if (parent.Address != address(0)) {
            return "Parent";
        } else if (child.Address != address(0)) {
            return "Child";
        } else {
            return "Unregistered";
        }
    }


    // get parent struct
    function getParent() public view returns (Parent memory) {
        Parent storage parent = addressToParent[msg.sender];
        if ((parent.Address != address(0))) {
            return parent;
        } else {
            revert There_is_no_user();
        }
    }



    // get child struct
    function getChild() public view returns (Child memory) {
        Child storage child = addressToChild[msg.sender];
        if ((child.Address != address(0))) {
            return child;
        } else {
            revert There_is_no_user();
        }
    }

    function getChildrenList ()  external view returns (Child[] memory result ) {
         Parent storage parent = addressToParent[msg.sender];
         require(parent.Address == msg.sender, "There_Is_No_Such_Parent");
         result = new Child[](parent.children.length);
            for (uint i = 0; i < parent.children.length; i++) {
                result[i] = addressToChild[parent.children[i]];
            }
    }

    
    // getReleaseTime of child
    function getReleaseTime(address payable _child) public view returns (uint256) {
        Child storage child = addressToChild[_child];
        return child.releaseTime;
    }
    

    // get amount of ether from child balance , send to the msg.sender wallet
    function fund(address payable _child) public payable {
        // check the parent exist
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

        // check this child belongs to this parent
        uint256 size = parent.children.length;
        uint256 index;
        for (uint256 i = 0; i < size; i++) {
            if (parent.children[i] == _child) {
                index = i;
            }
        }
        if (index >= 0) {
            Child storage child = addressToChild[_child];
            emit Purchase(msg.sender, 1);
            child.amount += msg.value;
        } else {
            revert There_is_no_child_belongs_parent();
        }
    }

    receive() external payable {}

    fallback() external payable {}

    event Purchase(address indexed _invester, uint256 _amount);

    // parent can get amount of coin from his/her child balance ,msg.sender has to be parent
function withdrawParent(address payable _child,uint256 _amount)
        public
        payable
    {
        // check the parent exist
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

        console.log("-------------------------------");
        console.log(msg.sender);
        console.log(addressToChild[_child].invester);

        require(
            addressToChild[_child].invester == payable(msg.sender),
            "This_child_is_not_belongs_parent"
        );
        // get child
        Child storage child = addressToChild[_child];

        
        if (child.amount <  _amount) {
            revert Not_Enough_Funds();
        }
        child.amount -= _amount;
        address payable to = payable(msg.sender);
        // to.transfer(getBalance()); // bu şekilde child addresindeki ether değeri artıyor 
        to.transfer(_amount);
    }

    //  child can get amount of coin from his/her balance, msg.sender has to be child
    function withdrawChild(uint256 _amount)
        public
        payable
        
    {   
        // check the child exist
        Child storage child = addressToChild[msg.sender];
        require(
            child.Address != address(0),
            "There is no child with this address"
        );

        if (child.amount >= _amount) {
            emit Purchase(msg.sender, 1);
            child.amount -= _amount;
            payable(msg.sender).transfer(_amount); // send the amount of value to the parent address
        } else {
            revert There_is_no_enough_child_balance_to_draw();
        }
    }
}

/*
s
    // for string comparison 
     function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    } 

*/
