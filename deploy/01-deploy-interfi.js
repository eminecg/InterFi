const { network } = require("hardhat");
const { developmentChain } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId

    if (developmentChain.includes(network.name)) {
        console.log("Local Network detected! Deploying Mocks")
        await deploy(

        )
    }
    await deploy("interFi", {
        from: deployer,
        args: [],
        log: true
    });
}
module.exports.tags = ["interFi"]