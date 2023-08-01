// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function _getPrice(AggregatorV3Interface priceFeed) private view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = _getPrice(priceFeed);
        return (ethPrice * ethAmount) / 1e18;
    }
}
