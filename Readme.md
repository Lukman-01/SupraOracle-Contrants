# Solidity Smart Contract Assignments

This repository contains a series of Solidity smart contracts developed as part of a series of programming assignments. Each contract is designed with a focus on Solidity standards, security measures, and gas optimization.

## Description

The repository includes the following smart contracts:

1. **Token Sale Smart Contract**: Manages a token sale with presale and public sale phases, including features like cap on Ether raised, contribution limits, and immediate token distribution.
2. **Decentralized Voting System**: A voting system contract allowing user registration, candidate addition, and transparent, secure voting.
3. **Token Swap Smart Contract**: Facilitates swapping between two ERC-20 tokens at a predefined rate, ensuring secure and efficient exchanges.
4. **Multi-Signature Wallet**: A wallet contract requiring multiple signatures for transactions, ensuring collective control and security.

Each contract is developed using Foundry, a robust development environment for blockchain and smart contracts.

## Getting Started

### Prerequisites

- Solidity for smart contract development.
- Foundry for compiling and testing.
- Node.js and npm for JavaScript-based scripts.

### Installation and Setup

1. **Clone the Repository:**
   ```bash
   git clone  https://github.com/Lukman-01/SupraOracle-Contrants.git
   cd SupraOracle-Contrants
   ```

2. **Install Foundry:**
   - Follow the [Foundry installation documentation](https://foundry.paradigm.xyz/).

3. **Compile Contracts:**
   - Navigate to each contract directory.
   - Run `forge build` to compile the contracts.

### Testing

- **Run Tests:**
  - Each contract has its own set of tests in the `test` directory.
  - Use `forge test` in each contract's directory to run tests.
  - Ensure all tests pass to validate contract functionalities.
 
## Authors

- Abdulyekeen lukman