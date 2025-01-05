//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title Raffle
 * @author Pratham
 * @notice Raffle sample contract
 * @dev Chainlink  VRFv2.5 implementation
 */

contract Raffle {
    uint256 private immutable i_entranceFee; //for private variable we create constructors to define them

    constructor(uint256 _entranceFee) {
        i_entranceFee = _entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    // getter functions

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
