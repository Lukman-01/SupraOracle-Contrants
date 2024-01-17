// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import "../src/ERC20Token.sol"; 

contract ERC20TokenTest is DSTest {
    ERC20Token private token;
    address private constant ALICE = address(1);
    address private constant BOB = address(2);

    function setUp() public {
        token = new ERC20Token(1000);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000);
        assertEq(token.balanceOf(address(this)), 1000);
    }

    function testName() public {
        assertEq(token.name(), "Ibukun Token");
    }

    function testSymbol() public {
        assertEq(token.symbol(), "IBK");
    }

    function testDecimals() public {
        assertEq(token.decimals(), 18);
    }

    function testTransfer() public {
        assertTrue(token.transfer(ALICE, 100));
        assertEq(token.balanceOf(ALICE), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }

    function testFailTransferInsufficientBalance() public {
        token.transfer(ALICE, 1100); // Should fail
    }

    function testApproveAndAllowance() public {
        assertTrue(token.approve(ALICE, 200));
        assertEq(token.allowance(address(this), ALICE), 200);
    }

    function testTransferFrom() public {
        token.transfer(ALICE, 100);
        token.approve(BOB, 100);
        assertTrue(token.transferFrom(ALICE, BOB, 100));
        assertEq(token.balanceOf(BOB), 100);
    }

    function testFailTransferFromInsufficientAllowance() public {
        token.transfer(ALICE, 100);
        token.approve(BOB, 50);
        token.transferFrom(ALICE, BOB, 100); // Should fail
    }

    function testFailTransferToZeroAddress() public {
        token.transfer(address(0), 100); // Should fail
    }

    function testFailApproveZeroAddress() public {
        token.approve(address(0), 100); // Should fail
    }
}
