// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

error Already_has_two_parent_error();

contract User {

    enum Role {
        PARENT,
        CHILD
    }

    struct   PersonalData  {
        uint id;
        string firstName;
        string lastName;
        Role role;
        address walletAddress;
    } 

   
    

    mapping(address => uint256) public balances;

    function createUser() public {}

    function deleteUser() public {}

    function transactionHistory() public {}

    function getBalance() public {}


    function ageCalc(uint256 birthday, uint256 today)
        public
        pure
        returns (uint256)
    {
        uint startDate = birthday; // 2012-12-01 10:00:00
        uint endDate = today; // 2012-12-07 10:00:00
}

    function fund() public payable {}

    function withdraw() public {}

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}

contract Parent is User {
    uint256 childCount = 0;
    PersonalData[] public parents;

     struct ParentData{
         PersonalData personalData;
         uint _id;
         // ..
     }
    struct ChildData{
         PersonalData personalData;
         uint _id;
         // ..
     }

    

    function addParent(
        uint id,
        string memory _firstName,
        string memory _lastName,
        Role role,
        address walletAddress
    ) public {
        if (parents.length > 2) {
            revert Already_has_two_parent_error();
        }
        parents.push(
            PersonalData(id, _firstName, _lastName, role, walletAddress)
        );
    }

   
}

contract  Child is User {

  
   struct ChildData{
         PersonalData personalData;
         uint _id;
         // ..
     }   

    

}