// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ObeliskPresale is ReentrancyGuard, Ownable {
    IERC20 public obeliskToken;
    IERC20 public usdc;
    
    uint256 public constant TOKEN_PRICE = 0.01 ether; // $0.01 in ETH equivalent
    uint256 public constant EARLY_BIRD_BONUS = 20; // 20% bonus
    uint256 public constant EARLY_BIRD_THRESHOLD = 25000 ether; // First $25K
    
    uint256 public totalRaised;
    uint256 public tokensAllocated;
    bool public presaleActive = true;
    
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public tokensPurchased;
    
    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event PresaleEnded();
    
    constructor(address _obeliskToken, address _usdc) {
        obeliskToken = IERC20(_obeliskToken);
        usdc = IERC20(_usdc);
    }
    
    function buyWithETH() external payable nonReentrant {
        require(presaleActive, "Presale not active");
        require(msg.value > 0, "Must send ETH");
        
        uint256 tokenAmount = calculateTokenAmount(msg.value);
        
        // Apply early bird bonus if under threshold
        if (totalRaised < EARLY_BIRD_THRESHOLD) {
            tokenAmount = tokenAmount + (tokenAmount * EARLY_BIRD_BONUS / 100);
        }
        
        contributions[msg.sender] += msg.value;
        tokensPurchased[msg.sender] += tokenAmount;
        totalRaised += msg.value;
        tokensAllocated += tokenAmount;
        
        require(obeliskToken.transfer(msg.sender, tokenAmount), "Token transfer failed");
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
    
    function buyWithUSDC(uint256 usdcAmount) external nonReentrant {
        require(presaleActive, "Presale not active");
        require(usdcAmount > 0, "Must send USDC");
        
        require(usdc.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        
        uint256 tokenAmount = calculateTokenAmount(usdcAmount);
        
        // Apply early bird bonus if under threshold
        if (totalRaised < EARLY_BIRD_THRESHOLD) {
            tokenAmount = tokenAmount + (tokenAmount * EARLY_BIRD_BONUS / 100);
        }
        
        contributions[msg.sender] += usdcAmount;
        tokensPurchased[msg.sender] += tokenAmount;
        totalRaised += usdcAmount;
        tokensAllocated += tokenAmount;
        
        require(obeliskToken.transfer(msg.sender, tokenAmount), "Token transfer failed");
        
        emit TokensPurchased(msg.sender, usdcAmount, tokenAmount);
    }
    
    function calculateTokenAmount(uint256 paymentAmount) public pure returns (uint256) {
        return paymentAmount / TOKEN_PRICE * 10**18;
    }
    
    function endPresale() external onlyOwner {
        presaleActive = false;
        emit PresaleEnded();
    }
    
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
        usdc.transfer(owner(), usdc.balanceOf(address(this)));
    }
    
    function emergencyWithdrawTokens() external onlyOwner {
        obeliskToken.transfer(owner(), obeliskToken.balanceOf(address(this)));
    }
}

