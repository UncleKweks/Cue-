// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PaymentPlan} from "../src/PaymentPlan.sol";

contract DeployPaymentPlan is Script {
    function run() external returns (PaymentPlan) {
        address payable seller = payable(
            0x51C78a61C4CF196c7cb46CF5170728a571718099
        );
        address arbiter = 0xC4b033d10Ab097cb12A872398E019499393eE34b;

        vm.startBroadcast();

        PaymentPlan paymentPlan = new PaymentPlan(seller, arbiter);

        vm.stopBroadcast();

        return paymentPlan;
    }
}
