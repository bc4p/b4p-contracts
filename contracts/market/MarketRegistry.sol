// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.12;

contract MarketRegistry {
    address[] public markets;
    function addMarket(address newMarket) external {
        markets.push(newMarket);
    }

    function getMarkets() public view returns(address[] memory){
        return markets;
    }
}