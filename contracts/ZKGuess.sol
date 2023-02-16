// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {GuessToken} from "./GuessToken.sol";


contract ZKGuess {

    /*
     *      EVENTS
     */

    event Winner(address indexed player, uint256 reward);
    event Loser(address indexed player, uint256 guess);
    event SecretNumberChanged();
    event OwnerChange(address newOwner);
    event TokenPauseStatusChanged(bool pauseStatus);
    
    /*
     *      STORAGE
     */

    GuessToken public guessToken;
    bool public paused = false;
    // Not so secret even though it is private ...
    uint256 private secretNumber;
    address private owner;

    /*
     *      MODIFIERS
     */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /*
     *      FUNCTIONS
     */

    constructor(address _token, uint256 _number) {
        guessToken = GuessToken(_token);
        secretNumber = _number;
        owner = msg.sender;
    }

    function guess(uint256 _number) public payable notPaused {
        
        require(msg.value == 0.01 ether, "Incorrect amount of ETH sent.");

        if (_number == secretNumber) {
            // 80% of the contract value plus 100 ERC-20 tokens.
            uint256 reward = (address(this).balance * 80) / 100;

            (bool sent, ) = payable(msg.sender).call{value: reward}("");
            require(sent, "Failed to send Ether");

            guessToken.mint(msg.sender, 100);
            emit Winner(msg.sender, reward);
        } else {
            emit Loser(msg.sender, _number);
        }
    }

    /*
     *      ADMIN FUNCTIONS
     */

    function setSecretNumber(uint256 _number) public onlyOwner {
        secretNumber = _number;
        emit SecretNumberChanged();
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
        emit OwnerChange(owner);
    }

    function togglePause() public onlyOwner {
        emit TokenPauseStatusChanged(
            paused = !paused
        );
    }

    // For retrieving testnet ETH from the contract
    // Not for production purposes, only for testnet deployments
    function reclaimEth() public onlyOwner {
        require(paused, "Contract must be paused to reclaim ETH");
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

}