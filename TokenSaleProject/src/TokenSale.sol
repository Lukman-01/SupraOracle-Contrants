// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Token.sol";
import {ITokenSaleErrors} from "./CustomErrors.sol";

/// @title A Contract for Managing Token Sales
/// @dev This contract handles the presale and public sale of ERC20 tokens
contract TokenSale is ITokenSaleErrors {
    ERC20Token public token; // The ERC20 token being sold
    address public owner; // Owner of the contract

    // Presale parameters
    uint256 public presaleCap; // Maximum amount to be raised in presale
    uint256 public presaleMinContribution; // Minimum contribution amount in presale
    uint256 public presaleMaxContribution; // Maximum contribution amount in presale
    uint256 public presaleEndTime; // End time of the presale
    uint256 public presaleTotalContributed; // Total amount contributed in presale
    mapping(address => uint256) public presaleContributions; // Mapping of contributors' addresses to their contributions in the presale

    // Public sale parameters
    uint256 public publicSaleCap; // Maximum amount to be raised in public sale
    uint256 public publicSaleMinContribution; // Minimum contribution amount in public sale
    uint256 public publicSaleMaxContribution; // Maximum contribution amount in public sale
    uint256 public publicSaleEndTime; // End time of the public sale
    uint256 public publicSaleTotalContributed; // Total amount contributed in public sale
    mapping(address => uint256) public publicSaleContributions; // Mapping of contributors' addresses to their contributions in the public sale

    // Minimum cap for each sale
    uint256 public presaleMinCap; // Minimum cap for presale
    uint256 public publicSaleMinCap; // Minimum cap for public sale

    // Events
    event PresaleContribution(address indexed contributor, uint256 amount);
    event PublicSaleContribution(address indexed contributor, uint256 amount);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    // Modifier to restrict certain functions to only the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorize");
        _;
    }

    /// @notice Creates a new token sale contract
    /// @dev Initializes the contract with token sale parameters
    /// @param _tokenAddress Address of the ERC20 token to be sold
    constructor(
        address _tokenAddress,
        uint256 _presaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _presaleEndTime,
        uint256 _publicSaleCap,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _publicSaleEndTime,
        uint256 _presaleMinCap,
        uint256 _publicSaleMinCap
    ) {
        owner = msg.sender; // Sets the contract deployer as the owner
        token = ERC20Token(_tokenAddress); // Initializes the ERC20 token

        // Setting up presale parameters
        presaleCap = _presaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        presaleEndTime = _presaleEndTime;

        // Setting up public sale parameters
        publicSaleCap = _publicSaleCap;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        publicSaleEndTime = _publicSaleEndTime;

        presaleMinCap = _presaleMinCap; // Minimum amount to be raised in presale
        publicSaleMinCap = _publicSaleMinCap; // Minimum amount to be raised in public sale
    }

    /// @notice Allows contributions to the presale
    /// @dev Function to handle presale contributions
    function contributeToPresale() external payable {
        // Custom error handling using imported ITokenSaleErrors interface
        if (block.timestamp > presaleEndTime) revert PresaleEnded();
        if (presaleTotalContributed + msg.value > presaleCap) revert PresaleCapReached();
        if (msg.value < presaleMinContribution) revert BelowPresaleMinContribution();
        if (msg.value > presaleMaxContribution) revert ExceedsPresaleMaxContribution();

        uint256 tokensToMint = (msg.value * 10**uint256(token.decimals())) / 1 ether;
        if (token.balanceOf(address(this)) < tokensToMint) revert InsufficientTokensInContract();

        presaleContributions[msg.sender] += msg.value;
        presaleTotalContributed += msg.value;
        token.transfer(msg.sender, tokensToMint);

        emit PresaleContribution(msg.sender, msg.value);
        emit TokensDistributed(msg.sender, tokensToMint);
    }

    /// @notice Allows contributions to the public sale
    /// @dev Function to handle public sale contributions
    function contributeToPublicSale() external payable {
        // Custom error handling using imported ITokenSaleErrors interface
        if (block.timestamp <= presaleEndTime) revert PublicSaleNotStarted();
        if (block.timestamp > publicSaleEndTime) revert PublicSaleEnded();
        if (publicSaleTotalContributed + msg.value > publicSaleCap) revert PublicSaleCapReached();
        if (msg.value < publicSaleMinContribution) revert BelowPublicSaleMinContribution();
        if (msg.value > publicSaleMaxContribution) revert ExceedsPublicSaleMaxContribution();

        uint256 tokensToMint = (msg.value * 10**uint256(token.decimals())) / 1 ether;
        if (token.balanceOf(address(this)) < tokensToMint) revert InsufficientTokensInContract();

        publicSaleContributions[msg.sender] += msg.value;
        publicSaleTotalContributed += msg.value;
        token.transfer(msg.sender, tokensToMint);

        emit PublicSaleContribution(msg.sender, msg.value);
        emit TokensDistributed(msg.sender, tokensToMint);
    }

    /// @notice Distributes tokens to a specified recipient
    /// @dev Can only be called by the owner of the contract
    /// @param recipient Address of the recipient
    /// @param amount Amount of tokens to distribute
    function distributeTokens(address recipient, uint256 amount) external onlyOwner {
        if (token.balanceOf(address(this)) < amount) revert InsufficientTokensInContract();
        token.transfer(recipient, amount);

        emit TokensDistributed(recipient, amount);
    }

    /// @notice Allows contributors to claim a refund under certain conditions
    /// @dev Refunds contributions if certain sale conditions are not met
    function claimRefund() external {
        // Custom error handling using imported ITokenSaleErrors interface
        if (block.timestamp <= publicSaleEndTime) revert PublicSaleNotEnded();
        if (publicSaleTotalContributed >= publicSaleMinCap) revert MinimumCapReached();
        if (publicSaleContributions[msg.sender] == 0) revert NoContributionToRefund();

        uint256 refundAmount = publicSaleContributions[msg.sender];
        publicSaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);

        emit RefundClaimed(msg.sender, refundAmount);
    }
}
