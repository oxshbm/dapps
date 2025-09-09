import "dotenv/config";
import { JsonRpcProvider } from "ethers";
import { JsonRpcApiProvider } from "ethers";


const provider = new JsonRpcProvider(process.env.RPC_URL);

const blockno = await provider.getBlockNumber();

console.log(await provider.getNetwork());

