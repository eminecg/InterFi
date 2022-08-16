const networkConfig = {
    4: {
        name: "rinkeby",
    },
    137: {
        name: "polygon",
    }
}
const developmentChain = ["hardhat", "localhost"]
const DECIMALS = 8
const INITIAL_ANSWER = 200000000

module.exports = {
    networkConfig,
    developmentChain,
    DECIMALS,
    INITIAL_ANSWER
}