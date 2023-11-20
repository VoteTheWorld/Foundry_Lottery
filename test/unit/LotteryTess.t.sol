//SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import {Lottery} from "../../src/Lottery.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract LotteryTest is Test {
    Lottery lottery;
    HelperConfig helperConfig;

    address vrfCoordinatorV2;
    uint64 subscriptionID;
    bytes32 gasLane; // keyHash
    uint32 callbackGasLimit;
    uint256 interval;
    uint256 entranceFee;
    address link;

    address public PLAYER = address(0x1);
    uint256 public constant STARTING_BALANCE = 100 ether;
    event Lottery_PlayerEntered(address indexed player);

    function setUp() external {
        DeployLottery deployLottery = new DeployLottery();
        (lottery, helperConfig) = deployLottery.run();

        (
            vrfCoordinatorV2,
            subscriptionID,
            gasLane, // keyHash
            callbackGasLimit,
            interval,
            entranceFee,
            link
        ) = helperConfig.config();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testEntryLottery() external {
        vm.prank(PLAYER);
        lottery.enterLottery{value: 0.1 ether}();
        assertEq(lottery.getPlayers(0), PLAYER);
        assertEq(address(lottery).balance, 0.1 ether);
    }

    function testPlayerEnteredEventEmited() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(lottery));
        emit Lottery_PlayerEntered(PLAYER);
        lottery.enterLottery{value: 0.1 ether}();
    }

    function testIfFalseWhenNoBalance() external {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        (bool upkeepNeeded, ) = lottery.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    modifier LotteryEntered() {
        vm.prank(PLAYER);
        lottery.enterLottery{value: 0.1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testEmitRequestId() external LotteryEntered {
        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 requestId = logs[1].topics[1];

        assert(uint256(requestId) != 0);
    }
}
