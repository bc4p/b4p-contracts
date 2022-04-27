// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./EnergyToken.sol";
import "./Market.sol";
import "./Node.sol";

abstract contract Asset is Node {
    EnergyToken token;
    address owner;

    constructor( 
    address ownerAddress, 
    address market1Address, 
    address market2Address,
    address marketRegistryAddress) 
    Node(market1Address,market2Address, marketRegistryAddress){
        owner = ownerAddress;
    }
}