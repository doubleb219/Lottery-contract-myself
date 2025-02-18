// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

/** 
 * @title Raffle contract
 * @author doubleb219 brownsbob56@gmail.com
 * @notice This contract is for creating a sample raffle.
 * @dev Implement Chainlink VRFv2.5
*/ 
contract Raffle {

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        
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