# Token Sale Smart Contract

This repository hosts a Solidity-based smart contract designed for managing token sales, including presale and public sale phases. The project leverages Foundry, a development environment, testing framework, and Ethereum Virtual Machine (EVM) for Solidity.

## Description

The smart contract suite includes:
1. **ERC20Token**: A basic ERC20 token contract, representing the digital asset being sold.
2. **TokenSale**: A contract that orchestrates the token sale process, covering various phases such as presale and public sale with parameters like sale caps, contribution limits, and timings.

## Getting Started

### Prerequisites

To get started, ensure you have the following:
- Foundry installed. If not, install it using `curl -L https://foundry.paradigm.xyz | bash`.
- An Ethereum wallet, such as MetaMask, for interactions with the deployed contract.

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Lukman-01/SupraOracle-Contrants.git
   cd TokenSaleProject
   ```

2. **Set up Foundry:**

   Initialize Foundry if it's not already set up in your project directory.

   ```bash
   forge init
   ```

3. **Install dependencies:**

   If the project uses external libraries, install them with Foundry.

   ```bash
   forge update
   ```

4. **Compile the smart contracts:**

   Compile the contracts using Foundry's `forge`.

   ```bash
   forge build
   ```

### Testing

The project includes a test suite to ensure contract functionalities:

- Run the tests using Foundry:

  ```bash
  forge test
  ```

## Authors

Blockchain Developer: Ibukun
Linkedin: https://www.linkedin.com/in/lukman-abdulyekeen-75746323a/

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.