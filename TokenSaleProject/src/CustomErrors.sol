// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Errors {

    error InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error InvalidSender(address sender);
    error InvalidReceiver(address receiver);
    error InvalidApprover(address approver);
    error InvalidSpender(address spender);

}
interface ITokenSaleErrors {

    error PresaleEnded();
    error PresaleCapReached();
    error BelowPresaleMinContribution();
    error ExceedsPresaleMaxContribution();
    error InsufficientTokensInContract();
    error PublicSaleNotStarted();
    error PublicSaleNotEnded();
    error PublicSaleEnded();
    error PublicSaleCapReached();
    error BelowPublicSaleMinContribution();
    error ExceedsPublicSaleMaxContribution();
    error MinimumCapReached();
    error NoContributionToRefund();

}