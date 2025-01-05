//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/**
 * @title Raffle
 * @author Pratham
 * @notice Raffle sample contract
 * @dev Chainlink  VRFv2.5 implementation
 */

contract Raffle {
    error Raffle__SendMoreETH();
    uint256 private immutable i_entranceFee; //for private variable we create constructors to define them
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    event RaffledEntered(address indexed player);

    constructor(uint256 _entranceFee, uint256 interval) {
        i_entranceFee = _entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp; //set at time of deployment
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) revert Raffle__SendMoreETH(); // custom error instead of require
        s_players.push(payable(msg.sender));

        emit RaffledEntered(msg.sender);
    }

    function pickWinner() external {
        //seeing if enough time has passed
        if (block.timestamp - s_lastTimeStamp < i_interval) revert();
        //get a random number

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    // getter functions

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
