// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployCueToken} from "../script/DeployCueToken.s.sol";
import {CueToken} from "../src/CueToken.sol";

contract CueTokenTest is Test {
    CueToken public cuetoken;
    DeployCueToken public deployer;

    address amara = makeAddr("amara");
    address amaka = makeAddr("amaka");
    address owner = address(this);
    address unknown = makeAddr("unknown");
    address[] public k7;


    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 70000000 * 10 ** 18;

    function setUp() public {
        deployer = new DeployCueToken();
        cuetoken = deployer.run();

        vm.prank(msg.sender);
        cuetoken.transfer(amara, STARTING_BALANCE);
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(cuetoken.totalSupply(), INITIAL_SUPPLY);
    }

    function testAmaraBalance() public view {
        assertEq(STARTING_BALANCE, cuetoken.balanceOf(amara));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Amara approves Amaka to spend tokens on her behalf

        vm.prank(amara);
        cuetoken.approve(amaka, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(amaka);
        cuetoken.transferFrom(amara, amaka, transferAmount);

        assertEq(cuetoken.balanceOf(amaka), transferAmount);
        assertEq(cuetoken.balanceOf(amara), STARTING_BALANCE - transferAmount);
    }

    function testMint() public {
        //Arrange

        //Check
        vm.prank(amaka);
        cuetoken.mint();
    }

    function testSetReward() public {
        uint256 newreward = 500;
        vm.startPrank(amaka);
        cuetoken.setRewardAmount(newreward);

        console.log("New Reward", newreward);
    }

    //function testRevertReward() public {
    //   vm.startPrank(owner);

    //   cuetoken.rewardUser(amaka);
    //  vm.expectRevert();
    //}

    function testTransfer() public {
        uint256 amount = 600000;
        vm.startPrank(msg.sender);
        cuetoken.transfer(unknown, amount);
    }

    function testAirdrop() public {
        uint256 amount = 5000;
        k7 = [amaka, unknown, amara];
        vm.startPrank(msg.sender);
        cuetoken.airdrop(k7, amount);
    }
}
