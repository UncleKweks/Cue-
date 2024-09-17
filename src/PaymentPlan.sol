// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Escrow Payment Plan
 * @notice This contract handles Payment
 * @author Kwesili Okafor
 */

// Contract Declaration
contract PaymentPlan {
    // Errors
    error InvalidAddresses();
    error InvalidAmounts();
    error IncorrectFundingAmount();
    error NextReleaseTimeNotReached();
    error AllPaymentsReleased();
    error FailedToSendEther();
    error InvalidRecipient();
    error DirectPaymentsNotAllowed();

    // Type Declarations
    enum State {
        Created,
        Funded,
        InProgress,
        Completed,
        Refunded,
        Disputed
    }

    // State Variables
    address payable public seller;
    address public arbiter;
    uint256 public totalAmount;
    uint256 public releaseAmount;
    uint256 public releasedAmount;
    uint256 public nextReleaseTime;
    uint256 public constant RELEASE_INTERVAL = 30 days;
    uint256 public amount;
    State public currentState;
    

    // Events
    event FundReceived(uint256 amount);
    event PaymentReleased(uint256 amount);
    event DisputeRaised(address initiator);
    event DisputeResolved(address resolver, address recipient, uint256 amount);
    event ContractCompleted();
    event ContractRefunded();

    // Modifiers
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this function");
        _;
    }

    modifier inState(State _state) {
        require(currentState == _state, "Invalid contract state");
        _;
    }

    mapping(address => uint256) private _buyers;

    // Constructor
    constructor(address payable _seller, address _arbiter) {
        if (_seller == address(0) || _arbiter == address(0))
            revert InvalidAddresses();

        seller = _seller;
        arbiter = msg.sender;
        currentState = State.Created;
    }

    // External Functions
    function fund() public payable   {
    require(msg.value > 0, "Funding amount must be greater than 0");
    
    amount = msg.value;

    
    
}

    function releasePayment() external onlySeller inState(State.Funded) {
        if (block.timestamp < nextReleaseTime)
            revert NextReleaseTimeNotReached();

        uint256 amountToRelease = address(this).balance;
        (bool success, ) = seller.call{value: amountToRelease}("");
        if (!success) revert FailedToSendEther();
        emit PaymentReleased(amountToRelease);
    }

    function raiseDispute() external {
        require(msg.sender == seller, " seller can raise a dispute");
        require(
            currentState == State.Funded,
            "Cannot raise dispute in current state"
        );
        currentState = State.Disputed;
        emit DisputeRaised(msg.sender);
    }

    function resolveDispute(
        address payable _recipient
    ) external onlyArbiter inState(State.Disputed) {
        if (_recipient != seller) revert InvalidRecipient();
        uint256 remainingAmount = address(this).balance;
        currentState = State.Completed;
        (bool success, ) = _recipient.call{value: remainingAmount}("");
        if (!success) revert FailedToSendEther();
        emit DisputeResolved(msg.sender, _recipient, remainingAmount);
        emit ContractCompleted();
    }

    function refund() external inState(State.Funded) {
        currentState = State.Refunded;
        uint256 refundAmount = _buyers[msg.sender];
        refundAmount = 0;
        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        if (!success) revert FailedToSendEther();
        emit ContractRefunded();
    }

    function getBuyersAddress(address buyers) external view returns (uint256) {
        return _buyers[buyers];
    }

    // View Functions
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractUserBalance() external view returns (uint256) {
        return _buyers[msg.sender];
    }

    // Fallback and Receive Functions
    receive() external payable {
        revert DirectPaymentsNotAllowed();
    }
}
