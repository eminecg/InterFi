// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
0x0000000000000000000000000000000000000000
 parent 
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
  child 1
0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7, 1598806220000 ,X
0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
  child 2
0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 1693414220000 ,Y
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

// TODO: 1. assign each created parent amount of CryptoBoxToken until reached 100. parent , then parent has to buy token with cost of bla bla ?? determine cost of token
// TODO: 2. each transaction request has its own release time , if release time is not passed , transaction will not be executed (?) 

// transaction ayni sekilde mi gerceklesicek ?
// parent cüzdanından token contract üzerinde mi tutulacak  yada  _allowance ile mi tutulacak ?

contract CryptoBoxToken is ERC20{
      constructor(uint256 initialSupply) ERC20("CryptoBox", "CB") {
         _mint(msg.sender, initialSupply);
    
    }
    

    // functions are overrided from ERC20 class

    /*


    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event   Transfer(address indexed from, address indexed to, uint256 value);
    event   Approval(address indexed owner, address indexed spender, uint256 value);

    */

    // _allowances , transactionları bu şekilde  map üstünde mi tutucaz contract üstünde tutmak yerine 
}
// 0x0fC5025C764cE34df352757e82f7B5c4Df39A836 contract address
contract CryptoBox {

    // contract related 
    
    address private owner;


    ERC20 public token;

    constructor() {
        owner = msg.sender;
        token = new CryptoBoxToken(50 ); // 50000000000000000000 wei
        
    }

    
    function totalSupply() public view   returns (uint256) {
        return token.totalSupply();
    }

        
    function getBalanceOfAddress(address payable _sender) public view  returns (uint256) {
        // not tested
        return token.balanceOf(_sender);
    }
     
    function getOwner() public view returns (address) {
        return owner;
    }


    // token related

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        token.transferFrom(msg.sender, address(this), amount);
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }

    

    // parent-child related

    

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

    // todo : transaction ların release time ları nasıl tutulacak
    

    mapping(address => Child) private addressToChild;
    mapping(address => Parent) private addressToParent;

   
    modifier onlyOwner() {        
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    modifier onlyisReleaseState() {
        bool state = checkReleaseTime(payable(msg.sender));
        if (state == false) {
            revert Not_released_yet();
        }
        _;
    }


    // todo:  add token to the each parent address until 100. parent
    function addParent(string memory _name) public {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address == address(0), "This_Parent_Already_Exist");

        parent.name = _name;
        parent.Address = payable(msg.sender);

        // transfer CryptoBoxToken to the parent from contract
        token.transfer(msg.sender, 10);

        // get remain token on contract
         uint256 remainToken = token.balanceOf(address(this));
        console.log("remain token on contract : ", remainToken);


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

    // todo: check releaseTime of the transaction request
    function checkReleaseTime(address payable _child) public view returns (bool) {
        console.log(block.timestamp*1000);
        Child storage child = addressToChild[_child];
        uint256 releaseTime = child.releaseTime;
        console.log(releaseTime);

        if ((block.timestamp*1000) > releaseTime) {
            return true;
        } else {
            return false;
        }
    }

   

  

    // todo: belli değil
    function getAmount(address payable _child) public view returns (uint256) {
        Child storage child = addressToChild[_child];
        return child.amount;
    }
    
    function getChildren() public view returns (address[] memory) {
        return addressToParent[msg.sender].children;
    }
   
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
    
    function getParent() public view returns (Parent memory) {
        Parent storage parent = addressToParent[msg.sender];
        if ((parent.Address != address(0))) {
            return parent;
        } else {
            revert There_is_no_user();
        }
    }
    
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

    
    // todo:  get the transaction release time
    function getReleaseTime(address payable _child) public view returns (uint256) {
        Child storage child = addressToChild[_child];
        return child.releaseTime;
    }
    

    // todo: parent transfer token to the child in general 

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


    // todo:  belli değil
    receive() external payable {}

    fallback() external payable {}

    event Purchase(address indexed _invester, uint256 _amount);


    // todo:  parent transfer token from the contract in general , belli değil
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

    // todo : child transfer token from the contract in general , belli değil
    //  child can get amount of coin from his/her balance, msg.sender has to be child
    function withdrawChild(uint256 _amount)
        public
        payable
        
    onlyisReleaseState {   
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

    // todo : belli değil
    function sumChildren() 
    public view 
    returns (uint256) {
    Parent storage parent = addressToParent[msg.sender];
    require(parent.Address != address(0), "There_Is_No_Such_Parent");
    uint256 sum = 0;
    uint256 size = parent.children.length;
    for (uint256 i = 0; i < size; i++) {
        sum += addressToChild[parent.children[i]].amount;
    }
    return sum;
    }

}