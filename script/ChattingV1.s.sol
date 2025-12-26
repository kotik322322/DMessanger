// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/ChattingV1.sol";

contract Deploy is Script {
    function run() external returns (ChattingV1 chatting) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        chatting = new Chatting();
        vm.stopBroadcast();
    }
}
