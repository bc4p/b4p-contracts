// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;
import "./Asset.sol";
contract ProducingAsset is Asset{
  
    constructor(address market2Address, address marketRegistryAddress) Asset(msg.sender, address(0), market2Address, marketRegistryAddress) {
        token = EnergyToken(market2.energyToken());
    }

    function forward(OfferOrBid memory offer, uint offerOrBidId) override internal {
        market2.receiveOffer(offer);
    }

    function acceptBid( uint price, uint amount, string memory bidId) external {
        OfferOrBid memory offer = OfferOrBid(block.timestamp, price, amount, address(this), address(this), false, "");
        token.produce(offer._address, offer.amount);
        market2.acceptBid(bidId,offer);
    }

    function createOffer(uint price, uint amount, string memory id) public {
        IERC20 stableCoin = IERC20(market2.stableCoin()); 
        address[] memory markets = registry.getMarkets();
        for(uint i=0; i<markets.length; i++){
            stableCoin.approve(markets[i], 1000000000000000000000);
        }
        OfferOrBid memory offer = OfferOrBid(block.timestamp, price, amount, address(this), address(this), false, id);
        token.produce(offer._address, offer.amount);
        forward(offer, 0);
    }
   
}