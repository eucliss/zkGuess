// Sources flattened with hardhat v2.12.7 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.7.3

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File contracts/ZKGuess.sol

pragma solidity >=0.8.0;

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
}
