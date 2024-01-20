// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/TokenA.sol";

contract MockTokenA is TokenA {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
