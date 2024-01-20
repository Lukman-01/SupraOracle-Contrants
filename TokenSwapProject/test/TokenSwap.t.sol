// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenSwap.sol";
import "./MockTokenA.sol";
import "./MockTokenB.sol";

contract TokenSwapTest is Test {
    TokenSwap public swapContract;
    MockTokenA public tokenA;
    MockTokenB public tokenB;
    uint256 rateAtoB = 1; // Example rate
    uint256 rateBtoA = 1; // Example rate
    address user = address(1);

    function setUp() public {
        // Deploy mock tokens
        tokenA = new MockTokenA();
        tokenB = new MockTokenB();

        // Deploy the swap contract
        swapContract = new TokenSwap(address(tokenA), address(tokenB), rateAtoB, rateBtoA);

        // Mint tokens to user and contract
        tokenA.mint(user, 1000 ether); // Minting TokenA to user
        tokenB.mint(user, 1000 ether); // Minting TokenB to user
        tokenA.mint(address(swapContract), 1000 ether); // Minting TokenA to TokenSwap contract
        tokenB.mint(address(swapContract), 1000 ether); // Minting TokenB to TokenSwap contract

        // Approve swapContract to spend user's tokens
        vm.startPrank(user);
        tokenA.approve(address(swapContract), type(uint256).max);
        tokenB.approve(address(swapContract), type(uint256).max);
        vm.stopPrank();
    }


    // Test swapAtoB
    function testSwapAtoB() public {
        uint256 amountA = 100 ether;
        uint256 expectedAmountB = amountA * rateAtoB;

        // Record initial balances
        uint256 initialBalanceAUser = tokenA.balanceOf(user);
        uint256 initialBalanceBUser = tokenB.balanceOf(user);

        vm.startPrank(user);
        swapContract.swapAtoB(amountA);
        vm.stopPrank();

        // Check final balances
        assertEq(tokenA.balanceOf(user), initialBalanceAUser - amountA);
        assertEq(tokenB.balanceOf(user), initialBalanceBUser + expectedAmountB);
    }

    // Test swapBtoA
    function testSwapBtoA() public {
        uint256 amountB = 100 ether;
        uint256 expectedAmountA = amountB * rateBtoA;

        // Record initial balances
        uint256 initialBalanceAUser = tokenA.balanceOf(user);
        uint256 initialBalanceBUser = tokenB.balanceOf(user);

        vm.startPrank(user);
        swapContract.swapBtoA(amountB);
        vm.stopPrank();

        // Check final balances
        assertEq(tokenA.balanceOf(user), initialBalanceAUser + expectedAmountA);
        assertEq(tokenB.balanceOf(user), initialBalanceBUser - amountB);
    }
}
