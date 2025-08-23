// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FounderVesting is Ownable {
    IERC20 public token;
    address public founder;
    uint256 public startTime;
    uint256 public constant TOTAL_TOKENS = 25_000_000 * 10**18; // 25M tokens
    uint256 public constant IMMEDIATE_UNLOCK = 20; // 20%
    uint256 public constant VESTING_DURATION = 365 days; // 12 months
    uint256 public claimedTokens;
    
    event TokensClaimed(uint256 amount);
    
    constructor(address _token, address _founder) {
        token = IERC20(_token);
        founder = _founder;
        startTime = block.timestamp;
        // Don't transfer tokens in constructor - they'll be transferred later
    }
    
    function claimTokens() external {
        require(msg.sender == founder, "Only founder can claim");
        
        uint256 claimableAmount = getClaimableTokens();
        require(claimableAmount > 0, "No tokens to claim");
        
        claimedTokens += claimableAmount;
        token.transfer(founder, claimableAmount);
        
        emit TokensClaimed(claimableAmount);
    }
    
    function getClaimableTokens() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        }
        
        uint256 elapsedTime = block.timestamp - startTime;
        
        // Calculate immediate unlock (20%)
        uint256 immediateUnlock = (TOTAL_TOKENS * IMMEDIATE_UNLOCK) / 100;
        
        if (elapsedTime >= VESTING_DURATION) {
            // Full vesting completed
            return TOTAL_TOKENS - claimedTokens;
        }
        
        // Calculate vested amount over time
        uint256 vestingAmount = (TOTAL_TOKENS * 80 * elapsedTime) / (100 * VESTING_DURATION);
        uint256 totalUnlocked = immediateUnlock + vestingAmount;
        
        return totalUnlocked - claimedTokens;
    }
    
    function setFounder(address _founder) external onlyOwner {
        founder = _founder;
    }
}
