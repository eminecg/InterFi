// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/*
0x0000000000000000000000000000000000000000
 parent 
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
  child 1
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678, 1598806220000 ,X
0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
  child 2
0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 1788876330000 ,Y
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
error Description_is_not_unique();

// TODO: 1. assign each created parent amount of CryptoBoxToken until reached 100. parent , then parent has to buy token with cost of bla bla ?? determine cost of token
// TODO: 2. each transaction request has its own release time , if release time is not passed , transaction will not be executed (?)

// transaction ayni sekilde mi gerceklesicek ?
// parent cüzdanından token contract üzerinde mi tutulacak  yada  _allowance ile mi tutulacak ?

abstract contract InterFi is Initializable, ERC20 {
    address private owner;

    function initialize() public initializer {
        _mint(msg.sender, 50000000000000000000);
        // assign owner
        owner = msg.sender;
        // transfer all tokens to the owner
        transfer(owner, 50000000000000000000);
    }

    function getBalanceOfAddress(address payable _sender)
        public
        view
        returns (uint256)
    {
        // not tested
        return balanceOf(_sender);
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    // call token approve function with owner address , owner aprove amount of token for the parent who will added later
    function approveToken(address _parent, uint256 _amount) public {
        approve(_parent, _amount);
    }

    // get the allowance of token for the parent
    function getAllowance(address _parent) public view returns (uint256) {
        return allowance(_parent, owner);
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
        uint256 amount;
        string name;
    }

    struct transaction {
        uint256 amount;
        uint256 releaseTime;
        bool isWithdrawn;
    }

    mapping(address => Child) private addressToChild;
    mapping(address => Parent) private addressToParent;
    // map child address to map key as unique description , value as transaction info
    mapping(address => mapping(string => transaction))
        private addressToTransaction;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    modifier onlyisReleaseState(string memory _description) {
        bool state = checkReleaseTime(payable(msg.sender), _description);
        if (state == false) {
            revert Not_released_yet();
        }
        _;
    }

    // a middleware for checking description of transaction is unique or not
    modifier onlyUniqueDescription(string memory _description) {
        bool state = checkDescription(payable(msg.sender), _description);
        if (state == true) {
            revert Description_is_not_unique();
        }
        _;
    }

    // function for checing description is unique or not between addressTransaction map value
    function checkDescription(
        address payable _address,
        string memory _description
    ) public view returns (bool) {
        if (addressToTransaction[_address][_description].amount == 0) {
            return false;
        }
        return true;
    }

    // todo:  add token to the each parent address until 100. parent
    function addParent(string memory _name) public {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address == address(0), "This_Parent_Already_Exist");

        parent.name = _name;
        parent.Address = payable(msg.sender);

        // transfer CryptoBoxToken to the parent from contract
        // token.transfer(msg.sender, 1 );               // 5 ether biriminde

        uint256 a = allowance(owner, msg.sender);
        console.log(a);

        uint256 b = allowance(msg.sender, owner);
        console.log(b);

        transferFrom(owner, msg.sender, 1000000000000000000);

        // get remain token on contract
        uint256 remainToken = balanceOf(owner);
        console.log("remain token on contract : ", remainToken);
    }

    function addChild(address payable _child, string memory _name) public {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

        Child storage child = addressToChild[_child];
        require(child.Address == address(0), "This_Child_Already_Exist");

        child.Address = _child;
        child.amount = 0;
        child.invester = payable(msg.sender);
        child.name = _name;
        parent.children.push(_child);
    }

    // todo: check releaseTime of the transaction request
    function checkReleaseTime(
        address payable _child,
        string memory _description
    ) public view returns (bool) {
        console.log("checkReleaseTime currentTime : ", block.timestamp * 1000);
        Child storage child = addressToChild[_child];
        require(
            child.Address != address(0),
            "There is no child with this address"
        );

        uint256 releaseTime = addressToTransaction[_child][_description]
            .releaseTime;
        require(releaseTime != 0, "There is no fund  with this description");

        //uint256 releaseTime = child.releaseTime;
        console.log(releaseTime);

        if ((block.timestamp * 1000) > releaseTime) {
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

    function getChildrenList() external view returns (Child[] memory result) {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address == msg.sender, "There_Is_No_Such_Parent");
        result = new Child[](parent.children.length);
        for (uint256 i = 0; i < parent.children.length; i++) {
            result[i] = addressToChild[parent.children[i]];
        }
    }

    function getReleaseTime(address payable _child, string memory _description)
        public
        view
        returns (uint256)
    {
        Child storage child = addressToChild[_child];
        require(child.Address != address(0), "There_Is_No_Such_Child");
        uint256 releaseTime = addressToTransaction[_child][_description]
            .releaseTime;
        return releaseTime;
    }

    function fund(
        address payable _child,
        uint256 _releaseTime,
        string memory uniqueDescription
    ) public payable onlyUniqueDescription(uniqueDescription) {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

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

            //_transfer(msg.sender,address(this), msg.value);
            increaseAllowance(_child, msg.value);

            // first check the description is exist or not
            bool state = checkDescription(_child, uniqueDescription);
            if (state == false) {
                // increase existence transaction amount
                addressToTransaction[_child][uniqueDescription].amount += msg
                    .value;
            } else {
                // create new transaction
                addressToTransaction[_child][uniqueDescription] = transaction(
                    msg.value,
                    _releaseTime,
                    false
                );
            }

            uint256 remainToken = balanceOf(msg.sender);
            console.log("remain token on parent : ", remainToken);

            uint256 allowance = allowance(msg.sender, _child);
            console.log("allowance token on child : ", allowance);
        } else {
            revert There_is_no_child_belongs_parent();
        }
    }

    // todo:  belli değil
    receive() external payable {}

    fallback() external payable {}

    event Purchase(address indexed _invester, uint256 _amount);

    // parent can get amount of coin from his/her child balance ,msg.sender has to be parent
    function withdrawParent(address payable _child, uint256 _amount)
        public
        payable
    {
        Parent storage parent = addressToParent[msg.sender];
        require(parent.Address != address(0), "There_Is_No_Such_Parent");

        console.log("-------------------------------");
        console.log(msg.sender);
        console.log(addressToChild[_child].invester);

        require(
            addressToChild[_child].invester == payable(msg.sender),
            "This_child_is_not_belongs_parent"
        );

        Child storage child = addressToChild[_child];

        if (child.amount < _amount) {
            revert Not_Enough_Funds();
        }
        child.amount -= _amount;

        // _transfer(address(this),msg.sender, _amount);
        decreaseAllowance(_child, _amount);
        uint256 allowance = allowance(msg.sender, _child);
        console.log("allowance token on child : ", allowance);

        uint256 remainToken = balanceOf(address(this));
        console.log("remain token on contract : ", remainToken);
    }

    //  child can get amount of coin from his/her balance, msg.sender has to be child
    function withdrawChild(uint256 _amount, string memory _uniqueDescription)
        public
        payable
        onlyisReleaseState(_uniqueDescription)
    {
        Child storage child = addressToChild[msg.sender];
        require(
            child.Address != address(0),
            "There is no child with this address"
        );

        if (child.amount >= _amount) {
            emit Purchase(msg.sender, 1);
            child.amount -= _amount;

            //payable(msg.sender).transfer(_amount); // send the amount of value to the parent address
            //transefer token from contract to child address
            _transfer(child.invester, msg.sender, _amount);
            decreaseAllowance(msg.sender, _amount);
            addressToTransaction[msg.sender][_uniqueDescription]
                .isWithdrawn = true;
        } else {
            revert There_is_no_enough_child_balance_to_draw();
        }
    }

    // todo : belli değil
    function sumChildren() public view returns (uint256) {
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
