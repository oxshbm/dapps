import "dotenv/config";
import { Wallet, JsonRpcProvider, ethers } from "ethers";

const provider = new JsonRpcProvider(process.env.RPC_URL);

const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

const tokenAddress = "0xYourTokenAddressHere";
const erc20ABI = [
  "function transfer(address to, uint amount) returns (bool)",
  "function decimals() view returns (uint8)"
];


const tokenContract = new ethers.Contract(tokenAddress, erc20ABI, wallet);

async function main() {
 
  const decimals = await tokenContract.decimals();

 
  const tx = await tokenContract.transfer(
    "0xRecipientAddressHere",          
    ethers.parseUnits("10", decimals)  )

  console.log("⏳ Transaction sent, hash:", tx.hash);

  const receipt = await tx.wait();
  console.log("✅ Transaction confirmed:", receipt.transactionHash);
}

main().catch(console.error);
