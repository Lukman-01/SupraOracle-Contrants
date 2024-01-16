// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Token.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";
import {ITokenSaleErrors} from "./CustomErrors.sol";

contract TokenSale is ITokenSaleErrors {
    ERC20Token public token;
    address public owner;

    // Presale details
    uint256 public presaleCap;
    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;
    uint256 public presaleEndTime;
    uint256 public presaleTotalContributed;
    mapping(address => uint256) public presaleContributions;

    // Public sale details
    uint256 public publicSaleCap;
    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;
    uint256 public publicSaleEndTime;
    uint256 public publicSaleTotalContributed;
    mapping(address => uint256) public publicSaleContributions;

    // Minimum cap for each sale
    uint256 public presaleMinCap;
    uint256 public publicSaleMinCap;

    // Events for logging
    event PresaleContribution(address indexed contributor, uint256 amount);
    event PublicSaleContribution(address indexed contributor, uint256 amount);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorize");
        _;
    }

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
        owner = msg.sender; 
        token = ERC20Token(_tokenAddress);

        presaleCap = _presaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        presaleEndTime = _presaleEndTime;

        publicSaleCap = _publicSaleCap;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        publicSaleEndTime = _publicSaleEndTime;

        presaleMinCap = _presaleMinCap;
        publicSaleMinCap = _publicSaleMinCap;
    }

    function contributeToPresale() external payable {
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

    function contributeToPublicSale() external payable {
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

    function distributeTokens(address recipient, uint256 amount) external onlyOwner {
        if (token.balanceOf(address(this)) < amount) revert InsufficientTokensInContract();
        token.transfer(recipient, amount);

        emit TokensDistributed(recipient, amount);
    }

    function claimRefund() external {
        if (block.timestamp <= publicSaleEndTime) revert PublicSaleNotEnded();
        if (publicSaleTotalContributed >= publicSaleMinCap) revert MinimumCapReached();
        if (publicSaleContributions[msg.sender] == 0) revert NoContributionToRefund();

        uint256 refundAmount = publicSaleContributions[msg.sender];
        publicSaleContributions[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);

        emit RefundClaimed(msg.sender, refundAmount);
    }
}
