// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "./Market.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import  "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./MarketRegistry.sol";

abstract contract Node is IERC1155Receiver {

Market public market1;
Market public market2;
MarketRegistry public registry;


mapping (address => uint) fees;
struct OfferOrBid {
        uint created_at;
        uint price;
        uint amount;
        address _address;
        address last_market;
        bool isBid;
}

constructor(address market1Address, address market2Address, address marketRegistryAddress){
    market1 = Market(market1Address);
    market2 = Market(market2Address);
    registry = MarketRegistry(marketRegistryAddress);

}

function setMarkets(address market1Address, address market2Address) public{
    market1 = Market(market1Address);
    market2 = Market(market2Address);
}

function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
}
 function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
    )
    external
    override
    returns(bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
    )
    external
    override
    returns(bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

function forward(OfferOrBid memory offerOrBid, uint offerOrBidId) internal virtual;

}