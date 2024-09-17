// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CueToken} from "../src/CueToken.sol";

//import {PaymentMethod} from "../src/PaymentMethod.sol";

contract DeployCueToken is Script {
    function run() external returns (CueToken) {
        vm.startBroadcast();
        CueToken cueToken = new CueToken();
        //PaymentMethod paymentmethod = new PaymentMethod();

        vm.stopBroadcast();
        return cueToken;
    }
}
