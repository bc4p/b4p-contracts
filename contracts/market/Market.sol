// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.12;
import "./EnergyToken.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./Node.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./MarketRegistry.sol";

contract Market is Node, KeeperCompatible{
    using Counters for Counters.Counter;

    //event that is raised when an offer and a bid match
    event Match(uint price, uint amount, uint timesatmp, address bidAddress, address offerAddress);

    uint public fee;
    uint public lastTimeStamp;
    uint public immutable interval;
    uint public counter;

    EnergyToken public energyToken;
    IERC20 public stableCoin;
    //AggregatorV3Interface priceFeed;

    //offers in the market
    mapping(uint => OfferOrBid) public offers; 
    //bids in the market 
    mapping(uint => OfferOrBid) public bids;  

    //track lenght of offers and bids
    Counters.Counter offersLength;
    Counters.Counter bidsLength;
    
    //deploy with a stablecoin (e.g Thether USD)
    //the price in bid/offers will refer to this stablecoin
    constructor(address stableCoinAddress,
     address energyTokenAddress, 
     address market1,
     address market2, 
     address marketRegistryAddress,
     uint _fee)
     Node(market1,market2,marketRegistryAddress)
     {
        fee = _fee;
        stableCoin = IERC20(stableCoinAddress);
        energyToken = EnergyToken(energyTokenAddress);
        interval = 15;
        lastTimeStamp = block.timestamp;
        counter = 0;
        registry.addMarket(address(this));
    }

    // energy providers will call this function sepcifying the price and a 
    // max amount of energy availabe to sell
    function receiveOffer(OfferOrBid memory offer) public{
        bool transferred = stableCoin.transferFrom(offer._address, address(this), (fee*offer.amount));
        require(transferred, "payment of fee failed");
        offer.price = offer.price+fee;
        bool offerMatched = _checkMatchOffer(offer);
        if(!offerMatched || offer.amount != 0){
            offers[offersLength.current()] = offer;
            offersLength.increment();
        }   
    }

    //energy consumer will call this function specigying the price and 
    //the amount they need.
    //the stable coins will be transferred to the smart contract untill an offer matches 
    //then they will be transferred to the provider.
    function receiveBid(OfferOrBid memory bid) public {
        //transferred = stableCoin.transferFrom(msg.sender, address(this), bid.price*bid.amount);
        //require(transferred, "transferred of stablecoins failed");
        //usdBalance[msg.sender] += bid.price*bid.amount;
        //bid.last_market = address(this);
        bool bidMatched = _checkMatchBid(bid);
        if(!bidMatched){
            bids[bidsLength.current()] = bid;
            bidsLength.increment();
        }
    }

    //check when a new offer enters the market if it has a match
    //if a match is found remove the bid
    function _checkMatchOffer(OfferOrBid memory offer) internal returns(bool) {
        for(uint i=0; i<bidsLength.current(); i++){
            OfferOrBid memory bid = bids[i];
            if(_match(bid, offer)){
                _removeBid(i);
                return true;
            }
        } 
        return false;
    }

    //chekc when a new bid enters the market if it has a match
    function _checkMatchBid(OfferOrBid memory bid) internal returns(bool) {
        for(uint i=0; i<offersLength.current(); i++){
            OfferOrBid memory offer = offers[i];
            if(_match(bid, offer)){
                if(offer.amount == 0)
                    _removeOffer(i);
                return true;
            }
        } 
        return false;
    }


    function _match(OfferOrBid memory bid, OfferOrBid memory offer) internal returns(bool) {
        if(bid.price >= offer.price && bid.amount<= offer.amount){
            emit Match(bid.price, bid.amount, block.timestamp, bid._address, offer._address);
            //energyToken.approve(bid._address, bid.amount);
            bool transferred = stableCoin.transferFrom(bid._address, offer._address, (bid.amount*bid.price));
            require(transferred, "stablecoin transfer failed");
            energyToken.transferFrom(offer._address, bid._address, bid.amount);
            offer.amount = offer.amount - bid.amount;
            return true;
        }
        return false;
    }


    function _removeBid(uint index)  public {
        require(index < bidsLength.current(), "wrong lenght");

        for (uint i = index; i<bidsLength.current()-1; i++){
            bids[i] = bids[i+1];
        }
        delete bids[bidsLength.current()-1];
        bidsLength.decrement();
    }

    function _removeOffer(uint index)  public {
        require(index < offersLength.current(), "wrong lenght");

        for (uint i = index; i<offersLength.current()-1; i++){
            offers[i] = offers[i+1];
        }
        delete offers[offersLength.current()-1];
        offersLength.decrement();
    }


    function forwardOffer(uint offerId) public {
        OfferOrBid memory offer = offers[offerId];
        forward(offer, offerId);
    }

    function forwardBid(uint bidId) public {
        OfferOrBid memory bid = bids[bidId];
        require(bid.price >= fee, "price not high enough");
        bool transferred = stableCoin.transferFrom(bid._address, address(this), fee*bid.amount);
        require(transferred, "payment of fee failed");
        bid.price = bid.price-fee;
        forward(bid, bidId);
    }

    function forward(OfferOrBid memory offerOrBid, uint offerOrBidId) override internal {
        require(address(market1)!= address(0) || address(market2)!= address(0), "market requires at least 1 connection");
        if(address(market1) == address(0)){
            if(offerOrBid.isBid){
                offerOrBid.last_market = address(this);
                market2.receiveBid(offerOrBid);
                _removeBid(offerOrBidId);
            }
            else{
                offerOrBid.last_market = address(this);
                market2.receiveOffer(offerOrBid);
                _removeOffer(offerOrBidId);
            }
        }
        else if(address(market2) == address(0)){
             if(offerOrBid.isBid){
                offerOrBid.last_market = address(this);
                market1.receiveBid(offerOrBid);
                _removeBid(offerOrBidId);
             }
            else{
                offerOrBid.last_market = address(this);
                market1.receiveOffer(offerOrBid);
                _removeOffer(offerOrBidId);
            }

        }

        else if(offerOrBid.last_market == address(market1)){
            if(offerOrBid.isBid){
                offerOrBid.last_market = address(this);
                market2.receiveBid(offerOrBid);
                _removeBid(offerOrBidId);
            }
            else{
                offerOrBid.last_market = address(this);
                market2.receiveOffer(offerOrBid);
                _removeOffer(offerOrBidId);
            }
        }
        else if(offerOrBid.last_market == address(market2)){
            if(offerOrBid.isBid){
                offerOrBid.last_market = address(this);
                market1.receiveBid(offerOrBid);
                _removeBid(offerOrBidId);
            }
            else{
                offerOrBid.last_market = address(this);
                market1.receiveOffer(offerOrBid);
                _removeOffer(offerOrBidId);
            }
        }

    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
            upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
            // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            counter = counter + 1;
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function getAddress() public returns(address){
        return address(this);
    }

 
}