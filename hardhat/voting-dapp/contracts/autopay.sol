```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 Autopay Template
 - Supports ETH (token == address(0)) and ERC20 tokens
 - Payer creates a subscription and deposits funds (initial deposit required)
 - Anyone (keeper/off-chain bot) can call processPayment to execute a due payment
 - Funds are held in contract as escrow; payee receives amount whenever a payment is processed
 - Payer can top-up, cancel, and withdraw leftover
*/

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AutoPay is ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public nextSubId;

    struct Subscription {
        address payer;
        address payee;
        address token;       // address(0) for native ETH
        uint256 amount;      // amount per interval
        uint256 interval;    // seconds between payments
        uint256 nextPayment; // timestamp of next payment
        uint256 balance;     // escrowed funds
        bool active;
    }

    mapping(uint256 => Subscription) public subscriptions;

    event SubscriptionCreated(
        uint256 indexed id,
        address indexed payer,
        address indexed payee,
        address token,
        uint256 amount,
        uint256 interval,
        uint256 nextPayment
    );
    event PaymentProcessed(uint256 indexed id, address indexed payee, uint256 amount, uint256 timestamp);
    event SubscriptionCancelled(uint256 indexed id, address indexed payer);
    event TopUp(uint256 indexed id, address indexed payer, uint256 amount);
    event Withdrawn(uint256 indexed id, address indexed payer, uint256 amount);

    modifier onlyPayer(uint256 id) {
        require(subscriptions[id].payer == msg.sender, "not payer");
        _;
    }

    modifier exists(uint256 id) {
        require(subscriptions[id].payer != address(0), "sub not found");
        _;
    }

    function createSubscription(
        address payee,
        address token,
        uint256 amount,
        uint256 intervalSeconds,
        uint256 startAt
    ) external payable nonReentrant returns (uint256 subId) {
        require(payee != address(0), "invalid payee");
        require(amount > 0, "amount > 0");
        require(intervalSeconds >= 60, "interval too small");

        subId = nextSubId++;
        uint256 initialDeposit;

        if (token == address(0)) {
            initialDeposit = msg.value;
            require(initialDeposit >= amount, "insufficient ETH deposit");
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            initialDeposit = amount;
        }

        uint256 firstPaymentTimestamp = startAt == 0
            ? block.timestamp + intervalSeconds
            : startAt;

        subscriptions[subId] = Subscription({
            payer: msg.sender,
            payee: payee,
            token: token,
            amount: amount,
            interval: intervalSeconds,
            nextPayment: firstPaymentTimestamp,
            balance: initialDeposit,
            active: true
        });

        emit SubscriptionCreated(
            subId,
            msg.sender,
            payee,
            token,
            amount,
            intervalSeconds,
            firstPaymentTimestamp
        );
    }

    function topUpETH(uint256 id) external payable nonReentrant exists(id) onlyPayer(id) {
        require(subscriptions[id].token == address(0), "not ETH");
        require(msg.value > 0, "no ETH sent");
        subscriptions[id].balance += msg.value;
        emit TopUp(id, msg.sender, msg.value);
    }

    function topUpERC20(uint256 id, uint256 amount) external nonReentrant exists(id) onlyPayer(id) {
        require(subscriptions[id].token != address(0), "sub is ETH");
        require(amount > 0, "amount 0");
        IERC20(subscriptions[id].token).safeTransferFrom(msg.sender, address(this), amount);
        subscriptions[id].balance += amount;
        emit TopUp(id, msg.sender, amount);
    }

    function cancelSubscription(uint256 id) external exists(id) onlyPayer(id) nonReentrant {
        subscriptions[id].active = false;
        emit SubscriptionCancelled(id, msg.sender);
    }

    function processPayment(uint256 id) public nonReentrant exists(id) returns (bool paid) {
        Subscription storage s = subscriptions[id];
        require(s.active, "inactive");
        require(block.timestamp >= s.nextPayment, "not due");
        require(s.balance >= s.amount, "insufficient balance");

        s.balance -= s.amount;
        s.nextPayment += s.interval;

        if (s.token == address(0)) {
            (bool sent, ) = s.payee.call{value: s.amount}("");
            require(sent, "ETH transfer failed");
        } else {
            IERC20(s.token).safeTransfer(s.payee, s.amount);
        }

        emit PaymentProcessed(id, s.payee, s.amount, block.timestamp);
        paid = true;
    }

    function processBatch(uint256[] calldata ids) external nonReentrant returns (uint256 processed) {
        for (uint256 i = 0; i < ids.length; ++i) {
            if (isDue(ids[i])) {
                processPayment(ids[i]);
                ++processed;
            }
        }
    }

    function withdrawRemaining(uint256 id) external nonReentrant exists(id) onlyPayer(id) {
        Subscription storage s = subscriptions[id];
        require(!s.active, "active");
        uint256 amt = s.balance;
        require(amt > 0, "no balance");
        s.balance = 0;

        if (s.token == address(0)) {
            (bool sent, ) = msg.sender.call{value: amt}("");
            require(sent, "ETH withdraw failed");
        } else {
            IERC20(s.token).safeTransfer(msg.sender, amt);
        }

        emit Withdrawn(id, msg.sender, amt);
    }

    function isDue(uint256 id) public view exists(id) returns (bool) {
        Subscription storage s = subscriptions[id];
        return s.active && block.timestamp >= s.nextPayment && s.balance >= s.amount;
    }

    receive() external payable {
        revert("use topUpETH");
    }

    fallback() external payable {
        revert("use topUpETH");
    }
}
```
