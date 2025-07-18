// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract BeggingContract {
    //合约所有者
    address public owner;
    //捐赠者mapping
    mapping(address => uint256) public donations;
    event Transfer(address indexed from, uint256 value);//记录捐赠事件
    
    constructor() {
        owner = msg.sender;
    }
    
    // 捐赠函数
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        donations[msg.sender] += msg.value;
        emit Transfer(msg.sender, msg.value);
    }
    
    // 提款函数（仅限合约所有者）
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }
    
    // 查询捐赠金额
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }
}