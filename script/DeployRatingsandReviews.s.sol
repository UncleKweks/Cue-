// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {RatingsandReviews} from "../src/RatingsandReviews.sol";
import {CueToken} from "../src/CueToken.sol";

contract DeployRatingsandReviews is Script {
    function run() external returns (RatingsandReviews) {
        vm.startBroadcast();

        RatingsandReviews ratingsandReviews = new RatingsandReviews();
        vm.stopBroadcast();

        return ratingsandReviews;
    }
}
