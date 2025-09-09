import "dotenv/config";
import { JsonRpcProvider, Wallet, formatEther } from "ethers";


const provider = new JsonRpcProvider(process.env.RPC_URL);

const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

console.log("Wallet address:", wallet.address);

const balance = await provider.getBalance(wallet.address);
console.log("Balance:", formatEther(balance), "ETH");
