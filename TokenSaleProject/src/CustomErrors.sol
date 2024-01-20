// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Token Sale Error Interface
 * @notice Defines custom errors for token sale processes
 * @dev This interface declares custom errors specific to a token sale process
 */
interface ITokenSaleErrors {
    /**
     * @notice Emitted when the presale period has ended
     */
    error PresaleEnded();

    /**
     * @notice Emitted when the presale cap (maximum limit) is reached
     */
    error PresaleCapReached();

    /**
     * @notice Emitted for contributions below the minimum in the presale
     */
    error BelowPresaleMinContribution();

    /**
     * @notice Emitted for contributions exceeding the maximum in the presale
     */
    error ExceedsPresaleMaxContribution();

    /**
     * @notice Emitted when there are insufficient tokens in the contract
     */
    error InsufficientTokensInContract();

    /**
     * @notice Emitted when the public sale has not yet started
     */
    error PublicSaleNotStarted();

    /**
     * @notice Emitted for operations attempted before the public sale ends
     */
    error PublicSaleNotEnded();

    /**
     * @notice Emitted when the public sale period has ended
     */
    error PublicSaleEnded();

    /**
     * @notice Emitted when the public sale cap is reached
     */
    error PublicSaleCapReached();

    /**
     * @notice Emitted for contributions below the minimum in the public sale
     */
    error BelowPublicSaleMinContribution();

    /**
     * @notice Emitted for contributions exceeding the maximum in the public sale
     */
    error ExceedsPublicSaleMaxContribution();

    /**
     * @notice Emitted when the minimum cap for the sale is reached
     */
    error MinimumCapReached();

    /**
     * @notice Emitted when there is no contribution to refund
     */
    error NoContributionToRefund();
}
