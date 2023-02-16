// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GuessToken is ERC20 {
    uint256 public constant MAX_SUPPLY = 10000000000000;

    event MintedTokens(uint256 amount, address recipient);
    event BurnedTokens(uint256 amount, address burner);

    constructor() ERC20("GuessToken", "GT"){
    }

    // Mint
    // Please dont mint all my tokens !!
    // @dev Clear vulnerability here, anyone can mint all the tokens.
    function mint(address to, uint256 amount) public {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max supply exceeded");
        _mint(to, amount);
        emit MintedTokens(amount, to);
    }

    function burn(uint256 amount) public {
        // Dont need to do any validation since the openzeppelin contract does it for us
        _burn(msg.sender, amount);
        emit BurnedTokens(amount, msg.sender);
    }
}

// The deployment is estimated to cost 0.000985312 ETH
// constructor args:0x
// GuessToken was deployed to 0xDB931F81E6A7976f34AC83C6dD9473F293ABD7dC