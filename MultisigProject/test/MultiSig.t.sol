// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MultiSig.sol";

contract MultiSigTest is Test {
    MultiSig multiSig;
    address[] owners;
    uint required;
    address owner1;
    address owner2;
    address owner3;

    function setUp() public {
        owners = [address(0x1), address(0x2), address(0x3)];
        required = 2;
        multiSig = new MultiSig(owners, required);
        owner1 = address(0x1);
        owner2 = address(0x2);
        owner3 = address(0x3);
    }

    function testConstructor() public {
        // Ensure the contract was initialized correctly
        assertEq(multiSig.owners(0), owner1);
        assertEq(multiSig.owners(1), owner2);
        assertEq(multiSig.owners(2), owner3);
        assertEq(multiSig.required(), required);
        assertEq(multiSig.getTransactionCount(), 0);
    }

    function testSubmitTransaction() public {
        // Submit a new transaction
        bytes memory data = hex"";
        uint256 value = 1 ether;

        vm.prank(owner1);
        multiSig.submitTransaction(address(this), value, data);

        // Verify the transaction was added
        assertEq(multiSig.getTransactionCount(), 1);
        (address destination, uint256 transactionValue, bytes memory transactionData, bool executed, bool canceled) = multiSig.transactions(0);
        assertEq(destination, address(this));
        assertEq(transactionValue, value);
        assertTrue(transactionData.length == 0);
        assertFalse(executed);
        assertFalse(canceled);
    }

    function testConfirmTransaction() public {
        // Submit a new transaction
        bytes memory data = hex"";
        uint256 value = 1 ether;

        vm.prank(owner1);
        multiSig.submitTransaction(address(this), value, data);

        // Confirm the transaction by owner2
        vm.prank(owner2);
        multiSig.confirmTransaction(0);

        // Verify the confirmation
        assertTrue(multiSig.confirmations(0, owner2));
        assertTrue(multiSig.isConfirmed(0));
    }

    function testExecuteTransaction() public {
        // Submit and confirm a new transaction
        bytes memory data = hex"";
        uint256 value = 1 ether;

        vm.prank(owner1);
        multiSig.submitTransaction(address(this), value, data);

        vm.prank(owner2);
        multiSig.confirmTransaction(0);

        // Execute the transaction
        vm.prank(owner1);
        multiSig.executeTransaction(0);

        // Verify the transaction was executed
        (, , , bool executed, ) = multiSig.transactions(0);
        assertTrue(executed);
    }

    function testCancelTransaction() public {
        // Submit a new transaction
        bytes memory data = hex"";
        uint256 value = 1 ether;

        vm.prank(owner1);
        multiSig.submitTransaction(address(this), value, data);

        // Cancel the transaction
        vm.prank(owner1);
        multiSig.cancelTransaction(0);

        // Verify the transaction was canceled
        (, , , , bool canceled) = multiSig.transactions(0);
        assertTrue(canceled);
    }

    function testRevertConditions() public {
        // Test submitting a transaction by a non-owner
        vm.expectRevert(MultiSig.OnlyOwners.selector);
        vm.prank(address(0xdead));
        multiSig.submitTransaction(address(this), 1 ether, "");

        // Test confirming a non-existent transaction
        vm.expectRevert(MultiSig.InvalidTransactionId.selector);
        vm.prank(owner1);
        multiSig.confirmTransaction(999);

        // Test executing a canceled transaction
        vm.prank(owner1);
        multiSig.submitTransaction(address(this), 1 ether, "");
        vm.prank(owner2);
        multiSig.confirmTransaction(0);
        vm.prank(owner1);
        multiSig.cancelTransaction(0);
        vm.expectRevert(MultiSig.TransactionAlreadyCanceled.selector);
        multiSig.executeTransaction(0);
    }
}
