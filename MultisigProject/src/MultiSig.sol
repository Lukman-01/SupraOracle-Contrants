// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultiSig Contract
 * @dev Implements a multi-signature contract where transactions require multiple confirmations.
 */
contract MultiSig {
    // Mapping to keep track of owners
    mapping(address => bool) public isOwner;
    // Array to store all owner addresses
    address[] public owners;
    // Number of confirmations required for a transaction to be executed
    uint256 public required;

    // Transaction structure to store transaction details
    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        bool canceled;
        uint256 confirmationsCount;
    }

    // Mapping of transaction ID to Transaction struct
    mapping(uint256 => Transaction) public transactions;
    // Total number of transactions (including executed and pending)
    uint256 public transactionCount;
    // Mapping to keep track of confirmations for each transaction
    mapping(uint256 => mapping(address => bool)) public confirmations;

    // Custom errors for better gas efficiency and clarity
    error OnlyOwners();
    error InvalidTransactionId();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyConfirmed();
    error TransactionAlreadyCanceled();
    error TransactionNotConfirmed();
    error TransactionExecutionFailed();
    error InvalidOwnerConfiguration(uint ownersLength, uint required);

    /**
     * @dev Modifier to restrict function access to only contract owners.
     */
    modifier onlyOwners() {
        if (!isOwner[msg.sender]) revert OnlyOwners();
        _;
    }

    /**
     * @dev Constructor to set up the MultiSig contract.
     * @param _owners List of owner addresses.
     * @param _required Number of required confirmations.
     */
    constructor(address[] memory _owners, uint256 _required) {
        if (_owners.length == 0 || _required == 0 || _required > _owners.length) 
            revert InvalidOwnerConfiguration(_owners.length, _required);

        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        required = _required;
    }

    /**
     * @dev Function to submit a new transaction to the contract.
     * @param _destination Destination address of the transaction.
     * @param _value Amount of Ether (in Wei) to send.
     * @param _data Data payload for the transaction.
     */
    function submitTransaction(address _destination, uint256 _value, bytes memory _data) public onlyOwners returns(uint256){
        uint256 transactionId = addTransaction(_destination, _value, _data);
        confirmTransaction(transactionId);
        return transactionId;
    }

    /**
     * @dev Internal function to add a new transaction.
     * @param _destination Destination address of the transaction.
     * @param _value Amount of Ether (in Wei) to send.
     * @param _data Data payload for the transaction.
     * @return The transaction ID.
     */
    function addTransaction(address _destination, uint256 _value, bytes memory _data) internal returns (uint256) {
        transactions[transactionCount] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            canceled: false,
            confirmationsCount: 0
        });

        transactionCount++;
        return transactionCount - 1;
    }

    /**
     * @dev Function to confirm a transaction.
     * @param _id Transaction ID to confirm.
     */
    function confirmTransaction(uint256 _id) public onlyOwners {
        if (_id >= transactionCount) revert InvalidTransactionId();

        Transaction storage transaction = transactions[_id];
        if (transaction.executed) revert TransactionAlreadyExecuted();
        if (confirmations[_id][msg.sender]) revert TransactionAlreadyConfirmed();

        confirmations[_id][msg.sender] = true;
        transaction.confirmationsCount++;

        if (isConfirmed(_id)) {
            executeTransaction(_id);
        }
    }

    /**
     * @dev Function to get the number of confirmations for a transaction.
     * @param _transactionId Transaction ID.
     * @return The number of confirmations.
     */
    function getConfirmationsCount(uint256 _transactionId) public view returns (uint256) {
        if (_transactionId >= transactionCount) revert InvalidTransactionId();
        return transactions[_transactionId].confirmationsCount;
    }

    /**
     * @dev Function to check if a transaction is confirmed.
     * @param _transactionId Transaction ID.
     * @return True if the transaction is confirmed, false otherwise.
     */
    function isConfirmed(uint256 _transactionId) public view returns (bool) {
        if (_transactionId >= transactionCount) revert InvalidTransactionId();

        return transactions[_transactionId].confirmationsCount >= required;
    }

    /**
     * @dev Function to execute a confirmed transaction.
     * @param _transactionId Transaction ID.
     */
    function executeTransaction(uint256 _transactionId) public onlyOwners {
        if (_transactionId >= transactionCount) revert InvalidTransactionId();

        Transaction storage transaction = transactions[_transactionId];
        if (transaction.executed) revert TransactionAlreadyExecuted();
        if (transaction.canceled) revert TransactionAlreadyCanceled();
        if (!isConfirmed(_transactionId)) revert TransactionNotConfirmed();

        transaction.executed = true;
        (bool success, ) = transaction.destination.call{value: transaction.value}(transaction.data);
        if (!success) revert TransactionExecutionFailed();
    }

    /**
     * @dev Function to cancel a transaction.
     * @param _transactionId Transaction ID.
     */
    function cancelTransaction(uint256 _transactionId) public onlyOwners {
        if (_transactionId >= transactionCount) revert InvalidTransactionId();

        Transaction storage transaction = transactions[_transactionId];
        if (transaction.executed) revert TransactionAlreadyExecuted();
        if (transaction.canceled) revert TransactionAlreadyCanceled();

        transaction.canceled = true;
    }

    /**
     * @dev Fallback function to accept Ether sent to the contract.
     */
    receive() external payable {}
}
