const { ethers, upgrades } = require('hardhat');

async function main() {
    const InterFiV2 = await ethers.getContractFactory('InterFiV2');
    console.log('Upgrading InterFi...');
    await upgrades.upgradeProxy('0x78FBaAaa1065D46444843d642c7Fdd8ec74D5eF1', InterFiV2);
    console.log('InterFi upgraded');
}

main();