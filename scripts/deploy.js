// pkg has default ethers so use it  so import from hardhat

const { ethers, run, network } = require("hardhat")

async function main() {
    const SimpleStorageFactory = await ethers.getContractFactory(
        "SimpleStorage"
    )
    console.log("Depolying Contract...")
    // do wait till it deploy
    const simpleStorage = await SimpleStorageFactory.deploy()

    // do wait till it deploy
    // await simpleStorage.deployed()
    console.log(`Deployed Contract to ${simpleStorage.address}`)

    // not verify hardhat local network so use chain id
    // console.log(network.config) // to see the chaid and network info
    if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
        // wait for few block -> wait for 6 block so the ether scan get so time to verify the contract
        console.log("Waiting for block confirmation ")
        await simpleStorage.deployTransaction.wait(6)
        await verify(simpleStorage.address, [])
    }

    const currentValue = await simpleStorage.retrieve()
    console.log(`Current Value is : ${currentValue}`)
    // update the value
    const transationResponse = await simpleStorage.store(54)
    await transationResponse.wait(1)
    const updatedValue = await simpleStorage.retrieve()
    console.log(`Updated value is ${updatedValue}`)

    // update the value
}
// Simple storage don't have a construntor so the args is goinging to be blank
async function verify(contractAddress, args) {
    // verfy the contrector: by a api to verify
    console.log("Verifying Contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!")
        } else {
            console.log(e)
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error)
        process.exit(1)
    })
