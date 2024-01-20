// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenSwap.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @dev A mock ERC20 token for testing purposes. It mimics a standard ERC20 token.
 */
contract MockERC20 is ERC20 {
    /**
     * @dev Constructor that mints 1 million tokens to the deployer's address.
     * @param name Name of the mock ERC20 token.
     * @param symbol Symbol of the mock ERC20 token.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

/**
 * @title FixedRateTokenSwapTest
 * @dev Test suite for the FixedRateTokenSwap contract.
 */
contract FixedRateTokenSwapTest is Test {
    FixedRateTokenSwap swap;
    MockERC20 tokenA;
    MockERC20 tokenB;
    uint256 rateAtoB = 1;
    uint256 rateBtoA = 1;

    /**
     * @dev Sets up the testing environment by deploying the tokens and swap contract.
     */
    function setUp() public {
        tokenA = new MockERC20("Token A", "TKA");
        tokenB = new MockERC20("Token B", "TKB");
        swap = new FixedRateTokenSwap(address(tokenA), address(tokenB), rateAtoB, rateBtoA);

        // Transfer some Token A and Token B to the swap contract for liquidity
        tokenA.transfer(address(swap), 500000 * 10 ** tokenA.decimals());
        tokenB.transfer(address(swap), 500000 * 10 ** tokenB.decimals());
    }

    /**
     * @dev Tests the swapAtoB function to ensure it swaps Token A for Token B correctly.
     */
    function testSwapAtoB() public {
        uint256 amountA = 100;
        uint256 expectedAmountB = amountA * rateAtoB;

        // Approve and swap tokens
        tokenA.approve(address(swap), amountA);
        swap.swapAtoB(amountA);

        // Check the final balance to ensure the swap was successful
        assertEq(tokenB.balanceOf(address(this)), expectedAmountB, "Swap A to B failed");
    }

    /**
     * @dev Tests the swapBtoA function to ensure it swaps Token B for Token A correctly.
     */
    function testSwapBtoA() public {
        uint256 amountB = 100;
        uint256 expectedAmountA = amountB * rateBtoA;

        // Approve and swap tokens
        tokenB.approve(address(swap), amountB);
        swap.swapBtoA(amountB);

        // Check the final balance to ensure the swap was successful
        assertEq(tokenA.balanceOf(address(this)), expectedAmountA, "Swap B to A failed");
    }
}
