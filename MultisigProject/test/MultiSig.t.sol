// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MultiSig.sol"; // Import your MultiSig contract

contract MultiSigTest is Test {
    MultiSig multiSig;
    address[] owners;
    uint256 required = 2;

    function setUp() public {
        owners = new address[](3);
        owners[0] = address(0x1);
        owners[1] = address(0x2);
        owners[2] = address(0x3);
        multiSig = new MultiSig(owners, required);

        // Send some Ether to the MultiSig contract for testing transactions that send Ether
        payable(address(multiSig)).transfer(10 ether);
    }


    // Test deployment and initial state
    function testDeployment() public {
        assertEq(multiSig.required(), required);
        for (uint i = 0; i < owners.length; i++) {
            assertTrue(multiSig.isOwner(owners[i]));
        }
    }

    // Test submission of a transaction
    function testSubmitTransaction() public {
        vm.prank(owners[0]); // Simulate call from the first owner
        address destination = address(0x42);
        uint256 value = 100;
        bytes memory data = hex"deadbeef";

        uint256 transactionId = multiSig.submitTransaction(destination, value, data);

        (address dest, uint256 val, bytes memory dat, bool executed, bool canceled, uint256 confirmationsCount) = multiSig.transactions(transactionId);
        
        assertEq(dest, destination);
        assertEq(val, value);
        assertEq(dat, data);
        assertFalse(executed);
        assertFalse(canceled);
        assertEq(confirmationsCount, 1); // Since submitTransaction also confirms the transaction
    }

    // Test confirming a transaction
    function testConfirmTransaction() public {
        vm.prank(owners[0]);
        uint256 transactionId = multiSig.submitTransaction(address(this), 0, bytes(""));

        assertEq(multiSig.getConfirmationsCount(transactionId), 1); // Already confirmed once
    }

    // Test executing a transaction
    function testExecuteTransaction() public {
        vm.prank(owners[0]);
        uint256 transactionId = multiSig.submitTransaction(address(this), 1 ether, bytes("")); // Transaction with 1 ether

        vm.prank(owners[1]);
        multiSig.confirmTransaction(transactionId);

        (, , , bool executed, , ) = multiSig.transactions(transactionId);
        assertTrue(executed);
    }

    // Test canceling a transaction
    function testCancelTransaction() public {
        vm.prank(owners[0]);
        uint256 transactionId = multiSig.submitTransaction(address(this), 0, bytes(""));

        vm.prank(owners[0]);
        multiSig.cancelTransaction(transactionId);

        (, , , , bool canceled, ) = multiSig.transactions(transactionId);
        assertTrue(canceled);
    }

    // Test revert on confirming transaction from non-owner
    function testFailConfirmTransactionNonOwner() public {
        uint256 transactionId = multiSig.submitTransaction(address(this), 0, bytes(""));
        vm.prank(address(0x4)); // Non-owner address
        multiSig.confirmTransaction(transactionId);
    }
}