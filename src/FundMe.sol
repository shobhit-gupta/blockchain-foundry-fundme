// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// 807,278 gas
// 786,716 gas
// 763,777 gas
// 763,765 gas
// 713,648 gas

error FundMe__NotOwner();
error FundMe__CallFailed();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_FUND_IN_USD = 5e18;
    address private immutable i_owner;

    address[] private s_funders;
    mapping(address funder => uint256 amount) private s_amountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) > MIN_FUND_IN_USD, "didn't send enough eth");
        s_funders.push(msg.sender);
        s_amountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        uint256 numFunders = s_funders.length;
        for (uint256 i = 0; i < numFunders; i++) {
            s_amountFunded[s_funders[i]] = 0;
        }
        s_funders = new address[](0);
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert FundMe__CallFailed();
        }
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getFunderAtIdx(uint256 idx) external view returns (address) {
        return s_funders[idx];
    }

    function getAmountFunded(address funder) external view returns (uint256) {
        return s_amountFunded[funder];
    }

    function getOwner() external view returns(address) {
        return i_owner;
    }

}
