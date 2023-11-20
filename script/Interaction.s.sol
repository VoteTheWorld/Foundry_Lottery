// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../test/mock/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract ADDSubscriptionId is Script {
    function run() external returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (address vrfCoordinatorV2, , , , , , ) = helperConfig.config();
        return createSubscriptionId(vrfCoordinatorV2);
    }

    function createSubscriptionId(
        address _vrfCoordinatorV2
    ) public returns (uint64 subId) {
        vm.startBroadcast();
        subId = VRFCoordinatorV2Mock(_vrfCoordinatorV2).createSubscription();
        vm.stopBroadcast();
    }
}

contract FundSubscription is Script {
    uint96 constant FUND_AMOUNT = 5 ether;

    function run() external {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            address vrfCoordinatorV2,
            uint64 subscriptionID,
            ,
            ,
            ,
            ,
            address link
        ) = helperConfig.config();
        fundSubscription(vrfCoordinatorV2, subscriptionID, link);
    }

    function fundSubscription(
        address vrfCoordinatorV2,
        uint64 subscriptionID,
        address link
    ) public {
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinatorV2).fundSubscription(
                subscriptionID,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinatorV2,
                FUND_AMOUNT,
                abi.encode(subscriptionID)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Lottery",
            block.chainid
        );
        AddConsumerConfig(mostRecentlyDeployed);
    }

    function AddConsumerConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();

        (
            address vrfCoordinatorV2,
            uint64 subscriptionID,
            ,
            ,
            ,
            ,

        ) = helperConfig.config();
        addConsumer(mostRecentlyDeployed, vrfCoordinatorV2, subscriptionID);
    }

    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint64 subId
    ) public {
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }
}
