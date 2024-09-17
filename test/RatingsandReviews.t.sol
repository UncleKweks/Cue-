// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {RatingsandReviews} from "../src/RatingsandReviews.sol";

contract RatingsandReview is Test {
    RatingsandReviews ratings;
    address public USER = makeAddr("user");
    uint256 public amount = 10000 ether;
    uint256 public _bookingid = 1;
    address public reviewer = address(0x1);

    function setUp() public {
        // ratings = new RatingsandReviews();
        // vm.deal(USER, amount);
    }

    // function testReviewCount() public {
    //     vm.prank(USER);
    //     uint256 count = ratings.getReviewCount();

    //     assertEq(count, 0);
    // }

    // function testSubmitReview() public {}
}
