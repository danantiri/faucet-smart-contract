// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract SepoliaFaucet {
    using Strings for uint256;

    // Owner of the faucet
    address public owner;
    
    // Amount to dispense (0.01 ETH)
    uint256 public DISPENSE_AMOUNT = 0.01 ether;
    
    // Cooldown period (1 day in seconds)
    uint256 public constant COOLDOWN_PERIOD = 1 days;
    
    // Mapping to track when users last received funds
    mapping(address => uint256) public lastRequestTime;
    
    // Events
    event FundsDispensed(address recipient, uint256 amount);
    event FundsDeposited(address depositor, uint256 amount);
    
    // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // Only owner modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    // Function to request funds
    function requestFunds() external {
        uint256 timeSinceLastRequest = block.timestamp - lastRequestTime[msg.sender];
        uint256 remainingTime = (COOLDOWN_PERIOD - timeSinceLastRequest) / 60;

        // Check if the user has waited the required cooldown period
        require(
            block.timestamp >= lastRequestTime[msg.sender] + COOLDOWN_PERIOD || lastRequestTime[msg.sender] == 0,
            string.concat("You must wait ", remainingTime.toString(), " minutes for next request")
        );
        
        // Check if the contract has enough balance
        require(address(this).balance >= DISPENSE_AMOUNT, "Faucet is empty");
        
        // Update the last request time
        lastRequestTime[msg.sender] = block.timestamp;
        
        // Send ETH to the requester
        (bool success, ) = payable(msg.sender).call{value: DISPENSE_AMOUNT}("");
        require(success, "Failed to send ETH");
        
        // Emit event
        emit FundsDispensed(msg.sender, DISPENSE_AMOUNT);
    }
    
    // Function to fund the faucet
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH to deposit");
        emit FundsDeposited(msg.sender, msg.value);
    }
    
    // Function to withdraw funds (owner only)
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Failed to withdraw ETH");
    }
    
    // Function to change owner (owner only)
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }

    // Function to change dispense amount (owner only)
    function setDispenseAmount(uint256 newAmount) external onlyOwner {
        require(newAmount > 0, "Dispense amount must be greater than 0");
        DISPENSE_AMOUNT = newAmount * 1 ether;
    }
    
    // Fallback function to receive ETH
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
}