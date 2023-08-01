// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address user = makeAddr("user");
    uint256 constant TEST_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    // uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(user, STARTING_BALANCE);
    }

    function testMinUSDIsFive() public {
        assertEq(fundMe.MIN_FUND_IN_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithZeroEth() public {
        vm.expectRevert();
        fundMe.fund();  // Sends 0 value
    }

    function testFundFailsWithLowEth() public {
        vm.expectRevert();
        fundMe.fund{value: 1e8}();
    }

    modifier funded() {
        vm.prank(user);
        fundMe.fund{value: TEST_VALUE}();
        _;
    }

    function testFundUpdateFunders() public funded {
        address funder = fundMe.getFunderAtIdx(0);
        assertEq(funder, user);
    }

    function testFundUpdatesAmountFunded() public funded {
        uint256 amountFunded = fundMe.getAmountFunded(user);
        assertEq(amountFunded, TEST_VALUE);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(user);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 preWithdrawContractBalance = address(fundMe).balance;
        uint256 preWithdrawOwnerBalance = fundMe.getOwner().balance;

        // uint256 preWithdrawGas = gasleft();
        // vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 postWithdrawContractBalance = address(fundMe).balance;
        uint256 postWithdrawOwnerBalance = fundMe.getOwner().balance;

        // uint256 postWithdrawGas = gasleft();
        // uint256 gasCost = (preWithdrawGas - postWithdrawGas) * tx.gasprice;

        assertEq(postWithdrawContractBalance, 0);
        assertEq(preWithdrawContractBalance, postWithdrawOwnerBalance - preWithdrawOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        uint256 numFunders = 10;

        for (uint160 i = 1; i <= numFunders; i++) {
            // i starts from 1 because we want to avoid address(0) in hoax call.
            // address(0) is a special address & may cause unintended reverts.
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: TEST_VALUE}();
        }

        uint256 preWithdrawContractBalance = address(fundMe).balance;
        uint256 preWithdrawOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 postWithdrawContractBalance = address(fundMe).balance;
        uint256 postWithdrawOwnerBalance = fundMe.getOwner().balance;

        assertEq(postWithdrawContractBalance, 0);
        assertEq(preWithdrawContractBalance, postWithdrawOwnerBalance - preWithdrawOwnerBalance);
    }


}
