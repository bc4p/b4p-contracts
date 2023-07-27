// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;
import "./Asset.sol";
contract ConsumingAsset is Asset{
  
    constructor(address market1Address, address marketRegistryAddress, address soulboundTokenAddress) Asset( msg.sender, market1Address, address(0), marketRegistryAddress,soulboundTokenAddress) {
        token = EnergyToken(market1.energyToken());
    }

    function forward(OfferOrBid memory bid, uint offerOrBidId) override internal {
        market1.receiveBid(bid);
    }

    function createBid(uint price, uint amount, string memory id) public {
        IERC20 stableCoin = IERC20(market1.stableCoin());
        address[] memory markets = registry.getMarkets();
        for(uint i=0; i<markets.length; i++){
            stableCoin.approve(markets[i], 1000000000000000000000);
        }
        ///stableCoin.approve(market1.getAddress(), 10000000000000000000);
        OfferOrBid memory bid = OfferOrBid(block.timestamp, price, amount, owner, owner, true, id);
        forward(bid, 0); 
    }
   
}