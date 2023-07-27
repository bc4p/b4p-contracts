// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./EnergyToken.sol";
import "./Market.sol";
import "./Node.sol";
import "../additional/SoulBoundToken.sol";

abstract contract Asset is Node {
    EnergyToken token;
    address owner;
    SoulBoundToken soulboundToken;


    constructor( 
    address ownerAddress, 
    address market1Address, 
    address market2Address,
    address marketRegistryAddress,
    address soulboundTokenAddress) 
    Node(market1Address,market2Address, marketRegistryAddress){
        soulboundToken = SoulBoundToken(soulboundTokenAddress);
        soulboundToken.addAddress(address(this));
        //(bool success, bytes memory result) = address(soulboundToken).delegatecall(abi.encodeWithSignature("addAddress(address)", address(this)));
        //require(success, "Delegatecall to addAddress setData failed");
        owner = ownerAddress;
    }
}