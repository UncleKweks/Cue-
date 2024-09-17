// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {PaymentPlan} from "../src/PaymentPlan.sol";

contract PaymentPlanTest is Test {
    address public user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user2");

    uint256 amount = 10000 ether;

    PaymentPlan payment;

    function setUp() public {
        payment = new PaymentPlan(payable(user2), payable(user3));
        vm.deal(user1, amount);
    }
}
