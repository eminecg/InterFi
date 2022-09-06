const { ethers, upgrades } = require('hardhat');

async function main() {
    const InterFi = await ethers.getContractFactory('InterFi');
    console.log('Deploying InterFi...');
    const interfi = await upgrades.deployProxy(InterFi, [], { initializer: 'initialize' });
    await interfi.deployed();
    console.log('İnterFi deployed to:', InterFi.address);
}

main();