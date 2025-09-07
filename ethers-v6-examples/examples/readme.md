# 🪄 Ethers.js Learning Quest: Building an On-Chain TODO List

Welcome, developer! This guide will walk you through learning **Ethers.js** while building a simple decentralized TODO app. Along the way, you'll discover *why* Ethers.js matters and the core concepts behind it.

---

## 📖 Why Ethers.js?

Think of Ethereum as a massive library. Inside it are countless books (smart contracts), each filled with spells (functions) written in an obscure language (bytecode). Humans can’t read or cast them directly.

You, the builder, have written your own book (smart contract). You want others to **open it, read its spells, and even cast them**. But without a translator, you’re stuck.

That’s where **Ethers.js** comes in. It’s like your **wand** for interacting with Ethereum:
- **Provider** → The librarian who fetches data about the blockchain.  
- **Signer** → Your identity, the one who signs transactions and proves they come from you.  
- **Contract** → The bridge that turns ABI definitions into callable JavaScript functions.  
- **Events** → Whispers from contracts when something happens (like state changes).  
- **Utils** → Handy tools for ETH conversion, address validation, and encoding.  

Without Ethers.js, you’d be left writing raw JSON-RPC requests (ugly hex strings). With it, working with Ethereum feels smooth and natural for web developers.

---

## 🚀 Practice Project: On-Chain TODO List

We’ll build a smart contract to manage tasks, then interact with it using Ethers.js.

### Step 1: Solidity Smart Contract (Todo.sol)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Todo {
    struct Task {
        string text;
        bool completed;
    }

    Task[] public tasks;

    event TaskAdded(uint id, string text);
    event TaskCompleted(uint id);

    function addTask(string calldata _text) external {
        tasks.push(Task(_text, false));
        emit TaskAdded(tasks.length - 1, _text);
    }

    function completeTask(uint _id) external {
        tasks[_id].completed = true;
        emit TaskCompleted(_id);
    }

    function getTasks() external view returns (Task[] memory) {
        return tasks;
    }
}
```

---

### Step 2: Deploy the Contract
- Deploy to a testnet (Sepolia/Goerli) or local Hardhat/Foundry node.  
- Save the **contract address** and **ABI**.  

---

### Step 3: Ethers.js Frontend Integration

#### Connect Wallet
```js
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
```

#### Load Contract
```js
const contract = new ethers.Contract(contractAddress, contractABI, signer);
```

#### Read Tasks
```js
const tasks = await contract.getTasks();
console.log(tasks);
```

#### Add Task
```js
const tx = await contract.addTask("Buy Milk");
await tx.wait();
```

#### Complete Task
```js
const tx = await contract.completeTask(0);
await tx.wait();
```

#### Listen for Events
```js
contract.on("TaskAdded", (id, text) => {
  console.log("Task Added:", id, text);
});
```

---

## 🎯 What You’ll Learn
- How **Providers** fetch blockchain data.  
- How **Signers** represent your wallet.  
- How **Contracts** turn ABI into real functions.  
- How **Events** keep your UI live and reactive.  
- How **Utils** simplify working with ETH and addresses.  

---

## 🧭 Next Steps
Once the TODO app works:
- Add **deadlines** or **owners** to tasks in Solidity.  
- Deploy on a **testnet** and share with friends.  
- Build a nicer **React + Ethers.js frontend** with task lists and buttons.  

With this quest, you now hold the wand (Ethers.js) to bend Ethereum to your will. ⚡
