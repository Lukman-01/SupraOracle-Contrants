// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ERC20 Error Interface
/// @notice Defines custom errors for ERC20 token operations
/// @dev This interface declares custom errors related to ERC20 tokens
interface IERC20Errors {

    /// @notice Emitted when a sender's balance is insufficient for a transaction
    /// @param sender Address attempting the transaction
    /// @param balance Current balance of the sender
    /// @param needed Amount required for the transaction
    error InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /// @notice Emitted when an invalid sender address is used
    /// @param sender Invalid sender address
    error InvalidSender(address sender);

    /// @notice Emitted when an invalid receiver address is used
    /// @param receiver Invalid receiver address
    error InvalidReceiver(address receiver);

    /// @notice Emitted when an invalid approver address is used in token approval
    /// @param approver Invalid approver address
    error InvalidApprover(address approver);

    /// @notice Emitted when an invalid spender address is used in token spending
    /// @param spender Invalid spender address
    error InvalidSpender(address spender);

}