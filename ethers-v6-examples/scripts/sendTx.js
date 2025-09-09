import "dotenv/config";
import { Wallet, JsonRpcProvider, parseEther } from "ethers";


const provider = new JsonRpcProvider(process.env.RPC_URL);


const wallet = new Wallet(process.env.PRIVATE_KEY, provider);

console.log("🔑 Using wallet:", wallet.address);


const tx = await wallet.sendTransaction({
  to: "0xA2CDc308BCadB75834eCda3F10440ec7455227f4", 
  value: parseEther("0.00000000001"),
});


const receipt = await tx.wait();

console.log("✅ Tx Hash:", tx.hash);
console.log("📜 Receipt:", receipt);
