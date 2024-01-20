# TokenSwapProject

This repository contains a Solidity-based smart contract framework designed for facilitating the exchange or swap of tokens. The project utilizes Foundry, an advanced development environment, testing framework, and Ethereum Virtual Machine (EVM) compatibility, tailored specifically for Solidity.

## Description

The smart contract suite encompasses:
1. **ERC20TokenA & ERC20TokenB**: Basic ERC20 token contracts, representing two different digital assets to be swapped.
2. **TokenSwap**: A contract that manages the token swapping mechanism, allowing users to exchange predetermined amounts of TokenA for TokenB and vice versa.

## Getting Started

### Prerequisites

Before starting, ensure you have the following:
- Foundry installed. If not, you can install it using:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   ```
- An Ethereum wallet, such as MetaMask, for interaction with the deployed contracts.

### Installation

1. **Clone the Repository:**
   
   ```bash
   git clone https://github.com/Lukman-01/SupraOracle-Contrants.git
   cd TokenSwapProject
   ```

2. **Set Up Foundry:**

   Initialize Foundry in your project directory if it's not already set up.

   ```bash
   forge init
   ```

3. **Install Dependencies:**

   Install any required external libraries with Foundry.

   ```bash
   forge update
   ```

4. **Compile the Smart Contracts:**

   Use Foundry's `forge` to compile the contracts.

   ```bash
   forge build
   ```

### Testing

The project includes a comprehensive test suite to validate the functionality of the contracts:

- Execute the tests using Foundry:

  ```bash
  forge test
  ```

## Authors

Blockchain Developer: Ibukun
Linkedin: https://www.linkedin.com/in/lukman-abdulyekeen-75746323a/
 