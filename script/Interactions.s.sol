// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";


contract Fund_FundMe is Script {
    uint256 public constant VALUE = 0.01 ether;

    function fund_FundMe(address addr) public {
        vm.startBroadcast();
        FundMe(payable(addr)).fund{value: VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", VALUE);
    }

    function run() external {
        address latestContractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fund_FundMe(latestContractAddress);
    }
}

contract Withdraw_FundMe is Script {
    function withdraw_FundMe(address addr) public {
        vm.startBroadcast();
        FundMe(payable(addr)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address latestContractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdraw_FundMe(latestContractAddress);
    }
}

