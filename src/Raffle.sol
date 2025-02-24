// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

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
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

    /* Type Declarations*/
    enum RaffleState {
        OPEN,
        CACULATING
    } 


    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] public s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;

    // Chainlink VRF related variables
    // address immutable i_vrfCoordinator;
    // // VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    RaffleState private s_raffleState;

    /** Events */
    event RaffleEntered(address indexed player); 
    event WinnerPicked(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;

        // i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_raffleState = RaffleState.OPEN;

    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }

        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    // When should the winner is picked?
    /** 
     * @dev This is the function that the chainlink nodes will call to see
     * if the lottery is ready to have a winner picked.
     * The following shold be true in orde for upkeepNeeded to be true:
     * 1. The time interval has passed between raffle runs
     * 2. The lottery is open
     * 3. The contract has ETH
     * 4. Implicitly, your subscription has LINK
     * @param - ignored
     * @return upkeepNeeded - true if it's time to restart the lottery
     * @return - ignored
    */ 
   function checkUpkeep(bytes memory /* checkkData */)
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded, "");
    }

    // 1. Get a random number
    // 2. Use the random number to pick a winner
    // 3. Automatically called
    function performUpkeep(bytes calldata /* performData */) external {
        // Check to see if enough time has passed
        // if(block.timestamp - s_lastTimeStamp < i_interval) {
        //     revert("Not enough time has passed");
        // }
        (bool upkeepNeeded, ) = checkUpkeep("");
        if(!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
        }
        s_raffleState = RaffleState.CACULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
            )
        });
        s_vrfCoordinator.requestRandomWords(request);

        // uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        
    }

    function fulfillRandomWords(uint256 /*requestId*/, uint256[] calldata randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(s_recentWinner);
    }
    /** 
     * Getter Function 
    */ 
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns(RaffleState) {
        return s_raffleState;
    }
 }