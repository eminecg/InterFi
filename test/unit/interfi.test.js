const { assert, expect } = require("chai")
const { ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")


describe("InterFi", function () {
    let interFi
    let owner, addr1, addr2
    let parentName = "XX"
    let childName = "YY"
    let givenReleaseTime = 1723830394 // 2024-08-16

    beforeEach(async () => {
        [owner, addr1, addr2] = await ethers.getSigners()
        interFiFactory = await ethers.getContractFactory("InterFi")
        interFi = await interFiFactory.deploy()
        await interFi.deployed()
    })

    describe("constructor", function () {
        it("sets the owner address correctly", async () => {
            const response = await interFi.getOwner()
            assert.equal(response, owner.address)
        })
    })

    describe("add Parent", function () {
        it("Add parent succesfully", async () => {
            const response = await interFi.addParent(parentName) // fonksiyonun doğru çalıştığını nasıl söyleriz ve ya direkt boş bırakacağız altını
        })
        it("Add parent gives error due to same address trying to add himself again", async () => {
            const response = await interFi.addParent(parentName)
            expect(response).to.be.revertedWith("This_Parent_Already_Exist")
        })
    })

    describe("add Child", function () {

        it("Add child succesfully", async () => {
            await interFi.addParent(parentName)
            const response = await interFi.addChild(addr1.address, givenReleaseTime, childName) // fonksiyonun doğru çalıştığını nasıl söyleriz ve ya direkt boş bırakacağız altını
        })
        it("Add child gives error for trying to add same child", async () => {
            await interFi.addParent(parentName)
            const response = await interFi.addChild(addr1.address, givenReleaseTime, childName)
            expect(response).to.be.revertedWith("This_Child_Already_Exist")
        })
        it("Add child gives error due to because there is no such parent", async () => {
            await interFi.addParent(parentName)
            owner = addr2
            const response = await interFi.addChild(addr1.address, givenReleaseTime, childName)
            expect(response).to.be.revertedWith("There_Is_No_Such_Parent")
            console.log(response)
        })
    })

    describe("ageCalc", function () {
        it("release time is true", async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(addr1.address, givenReleaseTime, childName)
            const response = await interFi.ageCalc(addr1.address)
            assert.equal(response.value, true) //  AssertionError: expected '[object Object]' to equal true
        })
        it("release time is false", async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(addr1.address, givenReleaseTime, childName)
            const response = await interFi.ageCalc(addr1.address)
            assert.equal(response.value, true) //  AssertionError: expected '[object Object]' to equal true
        })
    })

})