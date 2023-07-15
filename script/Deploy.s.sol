//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/Baubles.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ETH_PRIVATE_KEY");

        address ketherSortitionContract = vm.envAddress("KETHER_SORTITION_CONTRACT");

        vm.startBroadcast(deployerPrivateKey);

        Baubles baublesContract = new Baubles(IKetherSortition(ketherSortitionContract));

        vm.stopBroadcast();
    }
}
