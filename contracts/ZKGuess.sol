// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

    IERC20 public guessToken;
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
        guessToken = IERC20(_token);
        secretNumber = _number;
        owner = msg.sender;
    }

    function guess(uint256 _number) public payable notPaused {
        
        require(msg.value >= 0.01 ether, "You must pay to play");

        if (_number == secretNumber) {
            // 80% of the contract value plus 100 ERC-20 tokens.
            uint256 reward = (address(this).balance * 80) / 100;
            payable(msg.sender).transfer(reward); 
            guessToken.transfer(msg.sender, 100);
            emit Winner(msg.sender, reward);
        } else {
            // If it fails, the value is added to the contract.
            payable(address(this)).transfer(0.01 ether);

            // Return the excess ETH sent
            payable(msg.sender).transfer(msg.value - 0.01 ether);
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
        payable(msg.sender).transfer(address(this).balance);
    }

// Create another custom contract that uses the ERC-20 in some interesting form
//     ○ Create a contract, a secret number that stores a number.
//     ○ To play, you must guess the secret number.
//     ○ To guess, you have to pay in ETH, say, 0.001 ETH, to play.
//     ○ If you guess the number, you get 80% of the contract value plus 100 ERC-20 tokens.
//     ○ If it fails, the value is added to the contract.
// ● The contract should emit events whenever:
//     ○ the user pays
//     ○ there is a winner
//     ○ the user loses
//     ○ The deploying account should own the contract
//     ○ Only the owner can change the secret number
//     ○ Verify and flatten the contract

}