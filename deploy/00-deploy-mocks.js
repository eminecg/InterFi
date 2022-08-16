const { network } = require("hardhat")

module.exports = async ({ getNamedAccounts, deployments }) => {

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId
    await deploy("InterFi", {
        from: deployer,
        args: [],
        log: true
    });
}
module.exports.tags = ["all", "InterFi"]