# README - VotingContract Smart Contract

## Overview

This repository contains the VotingContract, a Solidity smart contract for conducting secure and transparent elections on the Ethereum blockchain. This project utilizes Foundry for its development environment, testing framework, and Ethereum Virtual Machine (EVM) compatibility. It's designed to manage various aspects of an election, including candidate registration, voter registration, and voting.

## Description

The smart contract suite includes:
1. **VotingContract**: The main contract facilitating the election process. It handles candidate and voter registrations, starting and ending elections, and recording votes.
2. **Test Suite**: A comprehensive set of tests using Foundry to ensure the contract's functionality and reliability.

## Getting Started

### Prerequisites

To get started, you will need:
- Foundry installed for contract testing and deployment. Install it using `curl -L https://foundry.paradigm.xyz | bash`.
- An Ethereum wallet, such as MetaMask, for interactions with the deployed contract.

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/Lukman-01/SupraOracle-Contrants.git
   cd VotingProject
   ```

2. **Set Up Foundry:**

   Initialize Foundry in your project directory.

   ```bash
   forge init
   ```

3. **Compile the Smart Contracts:**

   Compile the contracts using Foundry's `forge` command.

   ```bash
   forge build
   ```

### Testing

Run the test suite to ensure the functionality of the contract:

- Execute tests with Foundry:

  ```bash
  forge test
  ```

## Authors

Blockchain Developer: Ibukun
Linkedin: https://www.linkedin.com/in/lukman-abdulyekeen-75746323a/
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.