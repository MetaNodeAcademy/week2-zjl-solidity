// SPDX-License-Identifier: MIT
pragma  solidity ^0.8;
contract Voting {
    mapping(address => uint) public votes;
    address[] public userList;

    function vote(address _voter) public {
        votes[msg.sender] += 1;
        userList.push(_voter);
    }
    function getVote(address _voter) public view returns(uint) {
        return votes[_voter];
    }
    function resetVotes () public {
        for (uint i = 0;   i<userList.length ;i++){
            delete votes[userList[i]];
        }
        delete userList;
    }

    
    function reverseString(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint length = strBytes.length;
        for(uint i = 0; i < length/2; i++) {
            bytes1 temp = strBytes[i];
            strBytes[i] = strBytes[length-1-i];
            strBytes[length-1-i] = temp;
        }
        return string(strBytes);
    }
    
}