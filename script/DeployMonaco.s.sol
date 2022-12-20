// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import "../src/Monaco.sol";

contract DeployMonaco is Script {
    function setUp() public {
        // vm.createSelectFork("eth", 20302534);
    }

    function run() public {
        vm.startBroadcast();

        new Monaco();
    }
}
