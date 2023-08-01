// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Fund_FundMe, Withdraw_FundMe} from "../../script/Interactions.s.sol";


contract InteractionsTest is Test {
    FundMe fundMe;
    address user = makeAddr("user");
    uint256 constant TEST_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        Fund_FundMe fund_FundMe = new Fund_FundMe();
        fund_FundMe.fund_FundMe(address(fundMe));
        assertEq(address(fundMe).balance, fund_FundMe.VALUE());

        Withdraw_FundMe withdraw_FundMe = new Withdraw_FundMe();
        withdraw_FundMe.withdraw_FundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}