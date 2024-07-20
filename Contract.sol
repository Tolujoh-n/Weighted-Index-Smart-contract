// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WeightedIndex is ERC20, Ownable {
    // Addresses of the two tokens in the index
    address public token1;
    address public token2;

    // Weights of the two tokens, represented as percentages
    uint256 public weight1; // Weight for token1 (e.g., 60 for 60%)
    uint256 public weight2; // Weight for token2 (e.g., 40 for 40%)

    // Mock price feeds for the two tokens
    uint256 public price1; // Mock price for token1
    uint256 public price2; // Mock price for token2

    // Event to log rebalancing actions
    event Rebalanced(uint256 newWeight1, uint256 newWeight2);

    // Constructor to initialize the contract with token addresses and their weights
    constructor(
        address _token1,
        address _token2,
        uint256 _weight1,
        uint256 _weight2
    ) ERC20("Weighted Index Token", "WIT") Ownable(msg.sender) {
        require(_token1 != address(0) && _token2 != address(0), "Invalid token address");
        require(_weight1 + _weight2 == 100, "Weights must sum to 100");
        token1 = _token1;
        token2 = _token2;
        weight1 = _weight1;
        weight2 = _weight2;
    }

    // Function to set mock prices for the tokens, callable only by the contract owner
    function setMockPrices(uint256 _price1, uint256 _price2) external onlyOwner {
        require(_price1 > 0 && _price2 > 0, "Prices must be greater than zero");
        price1 = _price1;
        price2 = _price2;
    }

    // Function to calculate the current index value based on token prices and weights
    function calculateIndexValue() public view returns (uint256) {
        require(price1 > 0 && price2 > 0, "Prices must be set");
        uint256 totalValue1 = (price1 * weight1) / 100;
        uint256 totalValue2 = (price2 * weight2) / 100;
        return totalValue1 + totalValue2;
    }

    // Function to rebalance the weights of the tokens, callable only by the contract owner
    function rebalance(uint256 newWeight1, uint256 newWeight2) external onlyOwner {
        require(newWeight1 + newWeight2 == 100, "Weights must sum to 100");
        require(newWeight1 >= 0 && newWeight2 >= 0, "Weights must be non-negative");
        weight1 = newWeight1;
        weight2 = newWeight2;
        emit Rebalanced(newWeight1, newWeight2);
    }

    // Function to mint new index tokens, callable only by the contract owner
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");
        _mint(to, amount);
    }
}
