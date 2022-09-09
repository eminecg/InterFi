const { ethers, upgrades } = require('hardhat');

async function main() {
    const InterFiV2 = await ethers.getContractFactory('InterFiV2');
    console.log('Upgrading InterFi...');
    await upgrades.upgradeProxy('0x0ef4808A2Bf13908b57A4d45C2aE478ddC2c39fb', InterFiV2);
    console.log('InterFi upgraded');
}

main();