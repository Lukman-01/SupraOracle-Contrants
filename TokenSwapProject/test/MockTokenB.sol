// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/TokenB.sol";

contract MockTokenB is TokenB {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
