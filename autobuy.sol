pragma solidity ^0.8.0;

interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

contract AutoBuyToken {
    address public tokenAddress;
    address public owner;
    
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        owner = msg.sender;
    }
    
    function buyTokens(uint256 amount) external {
        require(amount > 0, "Amount should be greater than zero.");
        
        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender, amount);
    }
    
    function withdrawTokens(address to, uint256 amount) external {
        require(msg.sender == owner, "Only contract owner can call this function.");
        
        ERC20 token = ERC20(tokenAddress);
        token.transfer(to, amount);
    }
}
