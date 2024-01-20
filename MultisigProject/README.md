# MultiSig Smart Contract

This repository hosts a Solidity-based smart contract designed for managing multi-signature transactions. The project utilizes Foundry, a robust development environment, testing framework, and Ethereum Virtual Machine (EVM) interface, specifically tailored for Solidity development.

## Description

The smart contract suite includes:
1. **MultiSig**: The main contract that requires multiple confirmations from a set of owners to execute transactions. This enhances security and collaborative decision-making in Ethereum-based applications.
2. **MultiSigTest**: A comprehensive test suite for the MultiSig contract, ensuring all functionalities behave as expected.

## Getting Started

### Prerequisites

To use this project, you should have:
- Foundry installed. If it's not installed, you can install it using `curl -L https://foundry.paradigm.xyz | bash`.
- An Ethereum wallet, such as MetaMask, for interacting with the deployed contract.

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Lukman-01/SupraOracle-Contrants.git
   cd MultiSigProject
   ```

2. **Set up Foundry:**

   Initialize Foundry in your project directory if you haven't already.

   ```bash
   forge init
   ```

3. **Install dependencies:**

   Install any external libraries or dependencies using Foundry.

   ```bash
   forge update
   ```

4. **Compile the smart contracts:**

   Compile the contracts using Foundry's build system.

   ```bash
   forge build
   ```

### Testing

The project comes with a test script (`MultiSigTest.sol`) to verify the contract's functionality:

- Execute the tests with Foundry:

  ```bash
  forge test
  ```

## Authors

Blockchain Developer: Ibukun
Linkedin: [Lukman Abdulyekeen](https://www.linkedin.com/in/lukman-abdulyekeen-75746323a/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
