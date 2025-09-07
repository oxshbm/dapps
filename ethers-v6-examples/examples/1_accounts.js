require("dotenv").config();

const {ethers} = require("ethers")

const URL = `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`
const provider = new ethers.JsonRpcProvider(URL);

const ADDRESS = "0xFe648aADE7f40554272E9A381EbB263Caf3Ed3ca"

async function main() {
  // Get balance
  balance = await provider.getBalance(ADDRESS)

  // Log balance
  console.log(`balance if address ${ADDRESS} --> ${ethers.formatUnits(balance, 18)}`)
}

main()


