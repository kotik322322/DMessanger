// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {ChattingV1} from "../src/ChattingV1.sol";

contract TestChattingV1 is Test {
    ChattingV1 public chatting;

    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    address user4 = address(4);


    function setUp() public {
        chatting = new ChattingV1();
    }

    function testCreateGameMultipleTimesByUser() public {
        vm.startPrank(user1);
        chatting.createChatRoom();

        vm.expectRevert(ChattingV1.AddressAlreadyChatting.selector);
        chatting.createChatRoom();
        vm.stopPrank();
    }


}