// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Token.sol";
/**
 * @title TokenSwap
 * @dev A contract for swapping one ERC-20 token for another at a fixed exchange rate.
 */
contract TokenSwap {
    ERC20 public tokenA;
    ERC20 public tokenB;
    uint256 public exchangeRate; // Exchange rate from Token A to Token B (e.g., 1 Token A = X Token B)

    event Swap(address indexed user, uint256 amountA, uint256 amountB);

    /**
     * @dev Constructor function to initialize the TokenSwap contract.
     * @param _tokenAAddress The address of Token A.
     * @param _tokenBAddress The address of Token B.
     * @param _rate The fixed exchange rate from Token A to Token B.
     */
    constructor(address _tokenAAddress, address _tokenBAddress, uint256 _rate) {
        require(_rate > 0, "Exchange rate must be greater than zero");
        tokenA = ERC20(_tokenAAddress);
        tokenB = ERC20(_tokenBAddress);
        exchangeRate = _rate;
    }

    /**
     * @dev Allows users to swap Token A for Token B.
     * @param amountA The amount of Token A to swap.
     */
    function swapAToB(uint256 amountA) external {
        uint256 amountB = (amountA * exchangeRate) / 1 ether;
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed");
        emit Swap(msg.sender, amountA, amountB);
    }

    /**
     * @dev Allows users to swap Token B for Token A.
     * @param amountB The amount of Token B to swap.
     */
    function swapBToA(uint256 amountB) external {
        uint256 amountA = (amountB * 1 ether) / exchangeRate;
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer failed");
        require(tokenA.transfer(msg.sender, amountA), "Transfer failed");
        emit Swap(msg.sender, amountB, amountA);
    }
}
