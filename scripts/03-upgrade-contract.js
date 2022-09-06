const { ethers, upgrades } = require('hardhat');

async function main() {
    const InterFiV2 = await ethers.getContractFactory('InterFiV2');
    console.log('Upgrading InterFi...');
    await upgrades.upgradeProxy('0xD2e4BF24e77A02Ad60C873D7CD42f921CC212750', InterFiV2);
    console.log('InterFi upgraded');
}

main();