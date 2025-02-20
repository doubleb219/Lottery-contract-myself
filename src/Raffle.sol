// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/** `
 * @title Raffl e contract
 * @author doubleb219 brownsbob56@gmail.com
 * @notice This contracst is for creating a sample raffle.
 * @dev Implement Chainlink VRFv2.5
*/ 
contract Raffle is VRFConsumerBaseV2Plus {
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

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator) VRFConsumerBaseV2Plus(vrfCoordinator) {
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
        // requestId = s_vrfCoordinator.requestRandomWords(
        //     VRFV2PlusClient.RandomWordsRequest({
        //         keyHash: s_keyHash,
        //         subId: s_subscriptionId,
        //         requestConfirmations: requestConfirmations,
        //         callbackGasLimit: callbackGasLimit,
        //         numWords: numWords,
        //         extraArgs: VRFV2PlusClient._argsToBytes(
        //             // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
        //             VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
        //         )
        //     })
        // );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override{}
    /** 
     * Getter Function 
    */ 
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
 }