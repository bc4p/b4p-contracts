
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./EnergyToken2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EnergyTokenFactory {
    EnergyToken2[] public energyTokens;
    AggregatorV3Interface public priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(0x007A22900a3B98143368Bd5906f8E17e9867581b);

    }

    function createEnergyToken(string memory _uri) public{
        EnergyToken2 token = new EnergyToken2(_uri);
        energyTokens.push(token);
    }

    function getConversionRate() public view returns(int256){
        (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) =  priceFeed.latestRoundData();
    return answer;
    }
}
