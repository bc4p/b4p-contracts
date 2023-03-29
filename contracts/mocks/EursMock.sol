// SPDX-License-Identifier: MIT


pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EursMock is ERC20 {
    address private owner;
    constructor() ERC20("Euro", "EUR") {
        _mint(msg.sender, 10000 * 10**uint(decimals()));
        owner = msg.sender;
    }


    function createTokens(uint _amount) external {
        require(msg.sender == owner, "non-owner cannot mint tokens");
        _mint(msg.sender, _amount * 10**uint(decimals()));
    }
}