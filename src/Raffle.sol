// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";



/** 
 * @title Raffle contract
 * @author doubleb219 brownsbob56@gmail.com
 * @notice This contract is for creating a sample raffle.
 * @dev Implement Chainlink VRFv2.5
*/ 
contract Raffle {
    /** 
     * Error Messages 
    */
    error Raffle__SendMoreToEnterRaffle();


    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] public s_players;
    uint256 private s_lastTimeStamp;

    /** Events */
    event RaffleEntered(address indexed player); 

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        // check to see if enough time has passed

    }
    /** 
     * Getter Function 
    */ 
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
 }