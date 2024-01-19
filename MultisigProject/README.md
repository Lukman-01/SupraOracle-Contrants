# MultiSig Contract Project

## Overview
This project implements a MultiSig (multi-signature) smart contract in Solidity, designed for Ethereum blockchain. The contract allows a group of owners to collectively manage the execution of transactions, which require multiple confirmations before execution.

## Solidity Code
The main contract, `MultiSig`, is located in the `src` directory. It is written in Solidity version 0.8.20 and follows modern smart contract development practices.

### Contract Features
- Multi-signature functionality
- Transaction confirmation by multiple owners
- Execution of confirmed transactions
- Option to cancel transactions
- Owner management

## Design Choices
- **Modular Structure**: Functions are designed to be self-contained, improving readability and maintainability.
- **Owner Management**: Utilized a mapping for efficient owner verification and an array for enumeration.
- **Security Checks**: Implemented checks-effects-interactions pattern to mitigate reentrancy attacks.
- **Custom Errors**: Used for gas efficiency and clearer error handling.

## Security Considerations
- **Reentrancy Guard**: Ensured that state changes happen before external calls to prevent reentrancy attacks.
- **Input Validation**: Checked function inputs to prevent invalid or unauthorized actions.
- **Access Control**: Restricted critical functions to contract owners only.
- **Fail-Safe Mode**: Implemented cancel functionality to revoke transactions in case of an issue.

## Test Script
The test script is written using Foundry's `forge-std` and is located in the `test` directory. It demonstrates the contract's functionality through various test scenarios.

### Running Tests
To run the tests, use the following command:
```
forge test
```

## Test Cases
Test cases cover both typical usage and edge cases to ensure contract robustness. Key test cases include:
- Deployment and initialization
- Submitting, confirming, executing, and canceling transactions
- Checking for proper access control (only owners can execute certain actions)
- Edge cases like submitting a transaction with insufficient balance

## GitHub Repository
Find all the code, scripts, and documentation for this project at:
https://github.com/Lukman-01/SupraOracle-Contrants/tree/master/MultisigProject