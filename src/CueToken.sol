// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/* Errors */
error CannotMintToZeroAddress();
error AmountMustBeGreaterThanZero();
error TransferToZeroAddress();
error InvalidAddress();
error NoRecipients();
error AirdropToZeroAddress();
error TransferAmountExceedsAllowance();

/**
 * @title A Tokenized Reward System
 * @author Kwesili Okafor
 * @notice This contract is for creating an ERC20 Token
 */

contract CueToken is ERC20 {
    // State Variables

    uint256 public constant INITIAL_SUPPLY = 70000000 * 10 ** 18; // initial supply
    uint256 public rewardAmount;
    address public owner;

    //Events
    event TokensRewarded(address indexed user, uint256 amount);
    event TokensMinted(address indexed to, uint256 amount);
    event CustomTransfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event CustomApproval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event CustomTransferFrom(
        address indexed spender,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event TokensAirdropped(
        address indexed from,
        address[] recipients,
        uint256 amount
    );

    // Constructor
    /**
     * @notice Constructor to initialize the CueToken contract with an initial supply of tokens.
     */

    constructor() ERC20("CueToken", "CT") {
        _mint(msg.sender, INITIAL_SUPPLY);
        rewardAmount = 100 * 10 ** decimals();
        owner = msg.sender;
    }

    // External Functions

    /**
     * @notice Mints new tokens to the contract owner
     * @dev Only callable by the contract owner
     */

    function mint() external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        _mint(msg.sender, INITIAL_SUPPLY);
        emit TokensMinted(msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice Sets the amount of tokens to be rewarded
     * @dev Only callable by the contract owner
     * @param amount The new reward amount
     */

    function setRewardAmount(uint256 amount) external {
        if (owner != msg.sender) {
            revert("YOU_ARE_NOT_THE_OWNER");
        }
        rewardAmount = amount;
    }

    // Public Functions

    /**
     * @notice Transfers tokens to a specified address
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return success A boolean value indicating whether the operation succeeded
     */

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        if (to == address(0)) revert TransferToZeroAddress();
        if (amount == 0) revert AmountMustBeGreaterThanZero();

        _transfer(_msgSender(), to, amount);
        emit CustomTransfer(_msgSender(), to, amount);
        return true;
    }

    /**
     * @notice Approves a specified address to spend tokens on behalf of the caller
     * @param spender The address to approve
     * @param amount The amount of tokens to approve
     * @return success A boolean value indicating whether the operation succeeded
     */

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        emit CustomApproval(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @notice Transfers tokens from one address to another using an allowance mechanism
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return success A boolean value indicating whether the operation succeeded
     */

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        if (to == address(0)) revert TransferToZeroAddress();
        if (amount == 0) revert AmountMustBeGreaterThanZero();

        _transfer(from, to, amount);

        uint256 currentAllowance = allowance(from, _msgSender());
        if (currentAllowance < amount) revert TransferAmountExceedsAllowance();
        _approve(from, _msgSender(), currentAllowance - amount);

        emit CustomTransferFrom(_msgSender(), from, to, amount);
        return true;
    }

    /**
     * @notice Airdrops tokens to multiple recipients
     * @dev Only callable by the contract owner
     * @param recipients The list of recipient addresses
     * @param amount The amount of tokens to airdrop to each recipient
     */
    function airdrop(address[] calldata recipients, uint256 amount) external {
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        if (recipients.length == 0) revert NoRecipients();

        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] == address(0)) revert AirdropToZeroAddress();
            _mint(recipients[i], amount);
        }

        emit TokensAirdropped(msg.sender, recipients, amount);
    }
}
