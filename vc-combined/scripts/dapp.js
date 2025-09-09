import "dotenv/config";
import { Wallet, JsonRpcProvider, ethers } from "ethers";

const provider = new JsonRpcProvider(process.env.RPC_URL);


const wallet1 = Wallet.fromPhrase(process.env.MNEMONIC).connect(provider);
const wallet2 = Wallet.fromPhrase(process.env.MNEMONIC, "m/44'/60'/0'/0/1").connect(provider);

console.log("Wallet1:", wallet1.address);
console.log("Wallet2:", wallet2.address);


const tokenAddress = process.env.TOKEN_ADDRESS;
const erc20ABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
  "function balanceOf(address) view returns (uint256)",
  "function transfer(address to, uint amount) returns (bool)",
  "event Transfer(address indexed from, address indexed to, uint256 value)"
];

const token = new ethers.Contract(tokenAddress, erc20ABI, wallet1);


async function getBalance(address) {
  const decimals = await token.decimals();
  const balance = await token.balanceOf(address);
  return ethers.formatUnits(balance, decimals);
}


token.on("Transfer", (from, to, value, event) => {
  console.log(`💸 Transfer detected: ${ethers.formatUnits(value, 18)} tokens from ${from} to ${to}`);
});


async function main() {
  const symbol = await token.symbol();

  console.log(`\n📊 Initial Balances:`);
  console.log(`Wallet1: ${await getBalance(wallet1.address)} ${symbol}`);
  console.log(`Wallet2: ${await getBalance(wallet2.address)} ${symbol}`);

 
  const amount = ethers.parseUnits("1", 18); 
  console.log(`\n🚀 Sending 1 ${symbol} from Wallet1 to Wallet2...`);

  const tx = await token.transfer(wallet2.address, amount);
  console.log("Transaction sent:", tx.hash);

  await tx.wait();
  console.log("✅ Transaction confirmed!");

  console.log(`\n📊 Updated Balances:`);
  console.log(`Wallet1: ${await getBalance(wallet1.address)} ${symbol}`);
  console.log(`Wallet2: ${await getBalance(wallet2.address)} ${symbol}`);
}

main().catch(console.error);
