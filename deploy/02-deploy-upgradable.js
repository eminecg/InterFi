const { ethers, upgrades } = require('hardhat');

async function main() {
    const InterFi = await ethers.getContractFactory('InterFi');
    console.log('Deploying InterFi...');
    const box = await upgrades.deployProxy(InterFi, [], { initializer: 'setOwner' });
    await box.deployed();
    console.log('Box deployed to:', box.address);
}

main();