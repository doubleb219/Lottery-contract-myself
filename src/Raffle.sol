// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;


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
    address payable[] public s_players;

    /** Events */
    event RaffleEntered(address indexed player); 

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        
    }
    /** 
     * Getter Function 
    */ 
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
 }