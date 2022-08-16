const { use, expect } = require('chai');
const { ContractFactory, utils } = require('ethers');
const { MockProvider } = require('@ethereum-waffle/provider');
const { waffleChai } = require('@ethereum-waffle/chai');
const { deployMockContract } = require('@ethereum-waffle/mock-contract');

const interFi = "./build/interfi.json";
use(solidity);
const [wallet] = new MockProvider().getWallets()