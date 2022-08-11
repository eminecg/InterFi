// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.8;

// Import this file to use console.log
import "hardhat/console.sol";

error Already_has_two_parent_error();

contract User {
    enum Role {
        PARENT,
        CHILD
    }

    struct PersonalData {
        uint id;
        string firstName;
        string lastName;
        Role role;
    }

    mapping(address => uint256) public balances;

    function transactionHistory() public {}

    function getBalance(address index) public view returns (uint256) {
        return balances[index];
    }

    function ageCalc(uint256 birthday, uint256 today)
        public
        pure
        returns (uint256)
    {
        uint startDate = birthday; // 2012-12-01 10:00:00
        uint endDate = today; // 2012-12-07 10:00:00

        uint daysDiff = (endDate - startDate) / 60 / 60 / 24; // 6 days

        return daysDiff;
    }

    function fund() public payable {
        balances[msg.sender] += msg.value / 10**18;
    }

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

    function addParent(
        uint id,
        string memory _firstName,
        string memory _lastName,
        Role role
    ) public {
        if (parents.length > 2) {
            revert Already_has_two_parent_error();
        }
        parents.push(PersonalData(id, _firstName, _lastName, role));
    }
}
