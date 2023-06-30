pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}

contract AutoBuy {
    using SafeMath for uint256;

    address public owner;
    address public tokenAddress;
    uint256 public buyAmount;
    uint256 public buyInterval;
    uint256 public lastBuyTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    constructor(address _tokenAddress, uint256 _buyAmount, uint256 _buyInterval) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        buyAmount = _buyAmount;
        buyInterval = _buyInterval;
        lastBuyTime = block.timestamp;
    }

    function setBuyAmount(uint256 _buyAmount) external onlyOwner {
        buyAmount = _buyAmount;
    }

    function setBuyInterval(uint256 _buyInterval) external onlyOwner {
        buyInterval = _buyInterval;
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner, _amount), "Token transfer failed");
    }

    function buyTokens() external onlyOwner {
        require(block.timestamp >= lastBuyTime.add(buyInterval), "Buy interval has not passed yet");
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(owner, address(this), buyAmount), "Token transfer failed");
        lastBuyTime = block.timestamp;
    }
    
    function swapTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _routerAddress) external onlyOwner {
        require(_amountIn > 0, "Amount must be greater than 0");
        IERC20 token = IERC20(tokenAddress);
        require(token.approve(_routerAddress, _amountIn), "Token approval failed");
        IUniswapV2Router02 router = IUniswapV2Router02(_routerAddress);
        router.swapExactTokensForTokens(_amountIn, _amountOutMin, _path, address(this), block.timestamp.add(1800));
    }
}

