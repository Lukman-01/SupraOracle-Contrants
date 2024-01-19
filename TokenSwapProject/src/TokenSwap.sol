// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** 
 * @title FixedRateTokenSwap
 * @dev This contract facilitates the swapping of two ERC-20 tokens (Token A and Token B)
 * at a fixed, predefined exchange rate. It allows users to swap Token A for Token B and vice versa.
 * The contract uses custom error handling for improved gas efficiency and clarity.
 */
contract FixedRateTokenSwap {
    IERC20 public tokenA; // Reference to the contract of Token A
    IERC20 public tokenB; // Reference to the contract of Token B
    uint256 public rateAtoB; // Exchange rate from Token A to Token B
    uint256 public rateBtoA; // Exchange rate from Token B to Token A

    // Custom error declarations
    error InvalidTokenAddress(); // Error for invalid token addresses
    error FailedTransferTokenA(); // Error for failed transfer of Token A
    error InsufficientTokenBBalance(); // Error when the contract has insufficient Token B balance
    error FailedTransferTokenB(); // Error for failed transfer of Token B
    error InsufficientTokenABalance(); // Error when the contract has insufficient Token A balance

    // Event declarations
    event SwapAtoB(address indexed user, uint256 amountA, uint256 amountB); // Emitted when Token A is swapped for Token B
    event SwapBtoA(address indexed user, uint256 amountB, uint256 amountA); // Emitted when Token B is swapped for Token A

    /** 
     * @dev Constructor for FixedRateTokenSwap.
     * Initializes the contract with the addresses of Token A, Token B,
     * and the exchange rates for swapping the tokens.
     * @param _tokenA Address of Token A
     * @param _tokenB Address of Token B
     * @param _rateAtoB Exchange rate from Token A to Token B
     * @param _rateBtoA Exchange rate from Token B to Token A
     */
    constructor(address _tokenA, address _tokenB, uint256 _rateAtoB, uint256 _rateBtoA) {
        if (_tokenA == address(0) || _tokenB == address(0)) revert InvalidTokenAddress();
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        rateAtoB = _rateAtoB;
        rateBtoA = _rateBtoA;
    }

    /** 
     * @dev Swaps Token A for Token B based on the fixed exchange rate.
     * @param amountA The amount of Token A to swap.
     */
    function swapAtoB(uint256 amountA) external {
        uint256 amountB = amountA * rateAtoB;
        if (!tokenA.transferFrom(msg.sender, address(this), amountA)) revert FailedTransferTokenA();
        if (!tokenB.transfer(msg.sender, amountB)) revert InsufficientTokenBBalance();
        emit SwapAtoB(msg.sender, amountA, amountB);
    }

    /** 
     * @dev Swaps Token B for Token A based on the fixed exchange rate.
     * @param amountB The amount of Token B to swap.
     */
    function swapBtoA(uint256 amountB) external {
        uint256 amountA = amountB * rateBtoA;
        if (!tokenB.transferFrom(msg.sender, address(this), amountB)) revert FailedTransferTokenB();
        if (!tokenA.transfer(msg.sender, amountA)) revert InsufficientTokenABalance();
        emit SwapBtoA(msg.sender, amountB, amountA);
    }
}
