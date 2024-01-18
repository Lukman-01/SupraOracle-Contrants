// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing the interface IERC20Errors from another file named CustomErrors.sol
import {IERC20Errors} from "./CustomErrors.sol";

/**
 * @title A Basic ERC20 Token
 * @dev Implements the basic functionalities of an ERC20 token with custom error handling
 */
contract ERC20Token is IERC20Errors {
    // State variables
    string private _name = "Ibukun Token"; // Name of the token
    string private _symbol = "IBK"; // Symbol of the token
    uint8 private _decimal = 18; // Decimal precision of the token
    uint256 private _totalSupply; // Total supply of the token

    // Mapping to keep track of balances
    mapping(address => uint256) private _balances;
    // Nested mapping to keep track of allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    // Events
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /**
     * @notice Creates a new ERC20 token
     * @param total Initial total supply of the token
     */
    constructor(uint256 total) {
        _totalSupply = total; // Set the total supply
        _balances[msg.sender] = _totalSupply; // Assign the total supply to the contract creator
    }

    // Public Functions

    /**
     * @notice Returns the name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @notice Returns the symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Returns the decimal precision of the token
     */
    function decimals() public view returns (uint8) {
        return _decimal;
    }

    /**
     * @notice Returns the total supply of the token
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns the balance of a given account
     * @param account The address whose balance is being queried
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfers tokens to a specified address
     * @param recipient The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return A boolean value indicating whether the operation was successful
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @notice Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`
     * @param owner The address which owns the tokens
     * @param spender The address which will spend the tokens
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @notice Sets the allowance of a spender over the caller's tokens
     * @param spender The address authorized to spend
     * @param amount The amount of tokens to be spent
     * @return A boolean value indicating whether the operation was successful
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfers tokens from one address to another
     * @param sender The address which you want to send tokens from
     * @param recipient The address which you want to transfer to
     * @param amount The amount of tokens to be transferred
     * @return A boolean value indicating whether the operation was successful
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance < amount) revert InsufficientBalance(sender, currentAllowance, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    // Internal Functions

    /**
     * @dev Internal function to transfer tokens between addresses
     * @param sender The address sending tokens
     * @param recipient The address receiving tokens
     * @param amount The amount of tokens to transfer
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (sender == address(0)) revert InvalidSender(sender);
        if (recipient == address(0)) revert InvalidReceiver(recipient);
        if (_balances[sender] < amount) revert InsufficientBalance(sender, _balances[sender], amount);

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Internal function to set the allowance over an owner's tokens
     * @param owner The address which owns the tokens
     * @param spender The address which will spend the tokens
     * @param amount The amount of tokens to be allowed
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert InvalidApprover(owner);
        if (spender == address(0)) revert InvalidSpender(spender);

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Internal function to mint new tokens
     * @param account The address to receive the newly minted tokens
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal {
        if (account == address(0)) revert InvalidReceiver(account);

        _totalSupply += amount;
        _balances[account] += amount;
    }
}
