// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Lottery} from "../src/Lottery.sol";
import {ADDSubscriptionId, FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployLottery is Script {
    function run() external returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            address vrfCoordinatorV2,
            uint64 subscriptionID,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            uint256 interval,
            uint256 entranceFee,
            address link
        ) = helperConfig.config();

        if (subscriptionID == 0) {
            ADDSubscriptionId addSubscriptionId = new ADDSubscriptionId();
            subscriptionID = addSubscriptionId.createSubscriptionId(
                vrfCoordinatorV2
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinatorV2,
                subscriptionID,
                link
            );
        }

        vm.startBroadcast();
        Lottery lottery = new Lottery(
            vrfCoordinatorV2,
            subscriptionID,
            gasLane,
            callbackGasLimit,
            interval,
            entranceFee
        );
        vm.stopBroadcast();
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(lottery),
            vrfCoordinatorV2,
            subscriptionID
        );
        return (lottery, helperConfig);
    }
}
