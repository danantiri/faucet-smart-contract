// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SepoliaFaucet} from "../src/SepoliaFaucet.sol";

contract SepoliaFaucetScript is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        SepoliaFaucet sepoliaFaucet = new SepoliaFaucet();
        vm.stopBroadcast();
    }
}
