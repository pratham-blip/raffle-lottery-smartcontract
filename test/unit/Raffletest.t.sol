//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract Raffletest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 _entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("Player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed player);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        _entranceFee = config._entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleStateInitializedAsOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertWhenYouDonnotPayEnough() public {
        vm.prank(PLAYER);

        vm.expectRevert(Raffle.Raffle__SendMoreETH.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        vm.prank(PLAYER);

        raffle.enterRaffle{value: _entranceFee}();

        address PlayerRecorded = raffle.getPlayer(0);
        assert(PlayerRecorded == PLAYER);
    }

    function testEnterRaffleEmitsEvent() public {
        vm.prank(PLAYER);

        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);

        raffle.enterRaffle{value: _entranceFee}();
    }

    function testdontAllowEnterRaffleWhenRaffleIsNotOpen() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        console2.log(uint(raffle.getRaffleState())); //

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + 1);
        raffle.performUpkeep("");
        console2.log(uint(raffle.getRaffleState())); //

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        console2.log(uint(raffle.getRaffleState())); //
    }

    // performUpkeep tests

    function testCheckUpkeepRetuensFalseIfithasnoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.timestamp + 1);

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(!upkeepNeeded);
    }
    function testcheckUpkeepReturnFalseIfRaffleisntopen() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        assert(!upkeepNeeded);
    }

    //challamge
    //testcheckupkeepreturnsfalseifenoughtimehaspassed

    //testCheckUpKeepReturnsTrueWhenParametersAreGood

    ////perform upkeep///

    function PerformUpkeepWorkonlyWhenCheckUpkeepIsTrue() public {
        //arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //act //assert
        raffle.performUpkeep(""); //if this fails whole test fails
    }

    function testPerformUpkeepResvertsIfCHECKUPKEEPISFALSE() public {
        uint256 currBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rstate = raffle.getRaffleState();

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currBalance,
                numPlayers,
                rstate
            )
        );

        raffle.performUpkeep("");
    }

    modifier raffleEntered() {
        //arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdatesRaffleStatemiandetsRequestId()
        public
        raffleEntered ///////modifier//////
    {
        //act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes requestId = entries[1].topics[1];
        //assert

        Raffle.RaffleState rstate = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(rstate) == 1);
    }

    ////////////////////////fullFillRandomWords/////////////////////
}
