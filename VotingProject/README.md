# Voting Contract Project

## Overview
This repository contains the Solidity code for a blockchain-based voting system, designed to manage elections securely and transparently. The `VotingContract` allows for candidate registration, voter registration, and voting functionalities within a controlled election environment.

## Solidity Code
The core contract (`VotingContract.sol`) is written in Solidity and is deployed on the Ethereum blockchain. It handles the logic for starting and ending elections, registering candidates and voters, and casting votes.

## Design Choices
- **Access Control**: The contract uses modifiers to restrict certain functionalities to the contract owner and authorized voters.
- **State Management**: The contract maintains the state of the election, registered candidates, and voters, ensuring a clear and traceable election process.
- **Event Emission**: Events are emitted on key actions (e.g., candidate registration) to ensure transparency and enable off-chain tracking.

## Security Considerations
- **Owner Privileges**: Functions that can alter the election state (like starting and ending an election) are restricted to the contract owner.
- **Input Validation**: Inputs for functions (e.g., candidate and voter details) are validated to prevent invalid data entry.
- **Permissions**: The owner and users have limited permissions to some certain functions.

## Test Script
The `test` directory contains a Foundry-based test script (`VotingContract.t.sol`) that demonstrates the functionality of the smart contract. The script covers various aspects of the contract, ensuring all functionalities work as expected.

## Test Cases
The test cases cover:
- Contract initialization and access control.
- Starting and ending the election.
- Candidate and voter registration.
- Voting functionality and restrictions.
- Edge cases, such as attempting actions when not authorized or when the election is not active.

## How to Run Tests
To run the tests, navigate to the project directory and execute the following command:
```
forge test
```
This command runs the entire suite of tests and outputs the results.

## GitHub Repository
All the code, scripts, and documentation for this project are available in this GitHub repository. You can clone the repository using:
```
git clone  https://github.com/Lukman-01/SupraOracle-Contrants/tree/master/VotingProject
```

 