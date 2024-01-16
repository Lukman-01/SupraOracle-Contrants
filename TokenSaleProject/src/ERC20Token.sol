// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20Errors} from "./CustomErrors.sol";

contract ERC20Token is IERC20Errors{
    string private _name = "Ibukun Token";
    string private _symbol = "IBK";
    uint8 private _decimal = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // Constructor
    constructor(uint256 total) {
        _totalSupply = total;
        _balances[msg.sender] = _totalSupply;
    }

    // ERC20 Basic Functions
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance < amount) revert InsufficientBalance(sender, currentAllowance, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    // Internal Functions
    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (sender == address(0)) revert InvalidSender(sender);
        if (recipient == address(0)) revert InvalidReceiver(recipient);
        if (_balances[sender] < amount) revert InsufficientBalance(sender, _balances[sender], amount);

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        if (owner == address(0)) revert InvalidApprover(owner);
        if (spender == address(0)) revert InvalidSpender(spender);

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal {
        if (account == address(0)) revert InvalidReceiver(account);

        _totalSupply += amount;
        _balances[account] += amount;
    }
}
