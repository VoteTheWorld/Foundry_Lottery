//SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {VRFCoordinatorV2Mock} from "../test/mock/VRFCoordinatorV2Mock.sol";
import {Script} from "forge-std/Script.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";

contract HelperConfig is Script {
    NetworkConfig public config;

    uint96 BASE_FEE = 0.25 ether;
    uint96 GAS_PRICE_LINK = 1e9;

    struct NetworkConfig {
        address vrfCoordinatorV2;
        uint64 subscriptionID;
        bytes32 gasLane; // keyHash
        uint32 callbackGasLimit;
        uint256 interval;
        uint256 entranceFee;
        address link;
    }

    constructor() {
        if (block.chainid == 11155111) {
            config = getSeploiaConfig();
        } else if (block.chainid == 80001) {
            config = getMumbaiConfig();
        } else {
            config = getorCreateAnvilConfig();
        }
    }

    function getSeploiaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                vrfCoordinatorV2: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                subscriptionID: 7038,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                callbackGasLimit: 400000,
                interval: 60,
                entranceFee: 0.1 ether,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }

    function getMumbaiConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                vrfCoordinatorV2: 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed,
                subscriptionID: 6482,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, //not true
                callbackGasLimit: 400000,
                interval: 60,
                entranceFee: 0.1 ether,
                link: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
            });
    }

    function getorCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (config.vrfCoordinatorV2 != address(0)) {
            return config;
        }

        vm.startBroadcast();
        VRFCoordinatorV2Mock mock = new VRFCoordinatorV2Mock(
            BASE_FEE,
            GAS_PRICE_LINK
        );
        LinkToken link = new LinkToken();

        vm.stopBroadcast();

        return
            NetworkConfig({
                vrfCoordinatorV2: address(mock),
                subscriptionID: 0,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, //not true
                callbackGasLimit: 400000,
                interval: 60,
                entranceFee: 0.1 ether,
                link: address(link)
            });
    }
}
