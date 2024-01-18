import "forge-std/Test.sol";
import "../src/MultiSig.sol"; // Import your MultiSig contract

contract MultiSigTest is Test {
    MultiSig multiSig;
    address[] owners = [address(0x1), address(0x2), address(0x3)];
    uint256 required = 2;

    function setUp() public {
        multiSig = new MultiSig(owners, required);
    }

    // Test deployment
    test("deploys successfully") {
        assertTrue(address(multiSig) != address(0));
    }

    // Test constructor with invalid owner configuration
    test("reverts with invalid owner configuration") {
        // Provide invalid owner configuration
        try setup {
            MultiSig invalidMultiSig = new MultiSig(owners, 0);
        } catch {
            // Assert the expected revert message
            assertRevert(InvalidOwnerConfiguration(owners.length, 0));
        }
    }

    // Test transaction submission
    test("submits a transaction") {
        address destination = address(0x42);
        uint256 value = 100;
        bytes memory data = hex"deadbeef";

        uint256 transactionId = multiSig.submitTransaction(destination, value, data);
        assertTrue(transactionId > 0);
        assertEqual(multiSig.transactions[transactionId].destination, destination);
        assertEqual(multiSig.transactions[transactionId].value, value);
        assertEqual(multiSig.transactions[transactionId].data, data);
        assertFalse(multiSig.transactions[transactionId].executed);
        assertFalse(multiSig.transactions[transactionId].canceled);
    }

    // Test transaction confirmation
    test("confirms a transaction and executes when confirmed") {
        uint256 transactionId = multiSig.submitTransaction(address(this), 0, bytes(""));
        multiSig.confirmTransaction(transactionId); // Confirm once

        // Assert not executed yet (requires more confirmations)
        assertFalse(multiSig.transactions[transactionId].executed);

        // Confirm again to reach required confirmations
        address owner2 = owners[1];
        forge_setSender(owner2);
        multiSig.confirmTransaction(transactionId);

        // Assert transaction is executed
        assertTrue(multiSig.transactions[transactionId].executed);
    }

    // Test transaction cancellation
    test("cancels a transaction") {
        uint256 transactionId = multiSig.submitTransaction(address(this), 0, bytes(""));
        multiSig.cancelTransaction(transactionId);

        assertTrue(multiSig.transactions[transactionId].canceled);
        assertFalse(multiSig.transactions[transactionId].executed);
    }

    // Test onlyOwners modifier
    test("reverts when onlyOwners modifier fails") {
        try invoke {
            multiSig.confirmTransaction(0); // Call from a non-owner
        } catch {
            assertRevert(OnlyOwners());
        }
    }
}
