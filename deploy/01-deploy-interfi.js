const { network } = require("hardhat");
const { internalTask } = require("hardhat/config");
const { developmentChain } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify")
require("dotenv").config();

module.exports = async ({ getNamedAccounts, deployments }) => {

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();
    const verify = require("../utils/verify")

    if (!developmentChain.includes(network.name)) {
        interFi = await deploy("InterFi", {
            from: deployer,
            args: [],
            log: true,
            waitConfirmations: network.config.blockConfirmations || 1
        });
        console.log("deployed at", interFi.address)
    }


}
module.exports.tags = ["all", "InterFi"]