require("dotenv").config()
const { ethers } = require("ethers")

// Import private key helper
const { promptForKey } = require("../helpers/prompt.js")

const URL = process.env.TENDERLY_RPC_URL
const provider = new ethers.JsonRpcApiProvider(URL)
async function main() {
  const privateKey = await promptForKey()

  // Setup wallet

  // Get balances

  // Log balances

  // Create transaction

  // Wait transaction

  // Get balances

  // Log balances
}

main()