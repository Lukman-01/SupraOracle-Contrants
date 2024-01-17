// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/ERC20Token.sol"; 

/// @title Tests for ERC20Token Contract
/// @dev This contract uses ds-test framework for testing the ERC20Token functionalities
contract ERC20TokenTest is DSTest {
    ERC20Token private token; // Instance of ERC20Token to be tested
    address private constant ALICE = address(1); // Mock address for a user, here named ALICE
    address private constant BOB = address(2); // Mock address for another user, here named BOB

    /// @notice Setup function runs before each test
    function setUp() public {
        token = new ERC20Token(1000); // Create a new instance of ERC20Token with an initial supply of 1000
    }

    /// @notice Test the initial token supply
    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000); // Assert total supply is 1000
        assertEq(token.balanceOf(address(this)), 1000); // Assert the contract's balance is 1000
    }

    /// @notice Test the token's name
    function testName() public {
        assertEq(token.name(), "Ibukun Token"); // Assert the token's name is 'Ibukun Token'
    }

    /// @notice Test the token's symbol
    function testSymbol() public {
        assertEq(token.symbol(), "IBK"); // Assert the token's symbol is 'IBK'
    }

    /// @notice Test the token's decimal precision
    function testDecimals() public {
        assertEq(token.decimals(), 18); // Assert the token's decimal precision is 18
    }

    /// @notice Test successful token transfer
    function testTransfer() public {
        assertTrue(token.transfer(ALICE, 100)); // Assert that transferring 100 tokens to ALICE is successful
        assertEq(token.balanceOf(ALICE), 100); // Assert ALICE's balance is 100
        assertEq(token.balanceOf(address(this)), 900); // Assert the contract's balance is reduced to 900
    }

    /// @notice Test transfer with insufficient balance (should fail)
    function testFailTransferInsufficientBalance() public {
        token.transfer(ALICE, 1100); // This transfer should fail due to insufficient balance
    }

    /// @notice Test approval and allowance functionality
    function testApproveAndAllowance() public {
        assertTrue(token.approve(ALICE, 200)); // Approve ALICE to spend 200 tokens
        assertEq(token.allowance(address(this), ALICE), 200); // Assert allowance of ALICE is 200
    }

    /// @notice Test successful transferFrom functionality
    function testTransferFrom() public {
        token.transfer(ALICE, 100); // Transfer 100 tokens to ALICE
        token.approve(BOB, 100); // Approve BOB to spend 100 tokens
        assertTrue(token.transferFrom(ALICE, BOB, 100)); // Assert transferFrom is successful
        assertEq(token.balanceOf(BOB), 100); // Assert BOB's balance is 100
    }

    /// @notice Test transferFrom with insufficient allowance (should fail)
    function testFailTransferFromInsufficientAllowance() public {
        token.transfer(ALICE, 100); // Transfer 100 tokens to ALICE
        token.approve(BOB, 50); // Approve BOB to spend only 50 tokens
        token.transferFrom(ALICE, BOB, 100); // This transferFrom should fail
    }

    /// @notice Test transfer to zero address (should fail)
    function testFailTransferToZeroAddress() public {
        token.transfer(address(0), 100); // This transfer should fail
    }

    /// @notice Test approval to zero address (should fail)
    function testFailApproveZeroAddress() public {
        token.approve(address(0), 100); // This approval should fail
    }
}
