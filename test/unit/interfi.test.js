const { assert, expect } = require("chai")
const { ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")


describe("InterFi", function () {
    let interFi
    let parent, child1, child2, notParent
    let parentName = "XX"
    let childName = "YY"
    let givenReleaseTime = 1723830394 // 2024-08-16
    let secondReleaseTime = 986371774 // 2001-04-04
    let sendValue = ethers.utils.parseEther("2")
    let withdrawValue = ethers.utils.parseEther("1")

    beforeEach(async () => {
        [parent, child1, child2, notParent] = await ethers.getSigners()
        interFiFactory = await ethers.getContractFactory("InterFi")
        interFi = await interFiFactory.deploy()
        await interFi.deployed()
    })

    describe("constructor", function () {
        it("sets the parent address correctly", async () => {
            const response = await interFi.getOwner()
            assert.equal(response, parent.address)
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
            const response = await interFi.addChild(child1.address, givenReleaseTime, childName) // fonksiyonun doğru çalıştığını nasıl söyleriz ve ya direkt boş bırakacağız altını
        })
        it("Add child gives error for trying to add same child", async () => {
            await interFi.addParent(parentName)
            const response = await interFi.addChild(child1.address, givenReleaseTime, childName)
            expect(response).to.be.revertedWith("This_Child_Already_Exist")
        })
        it("Add child gives error due to because there is no such parent", async () => {
            await interFi.addParent(parentName)
            parent = child2
            const response = await interFi.addChild(child1.address, givenReleaseTime, childName)
            expect(response).to.be.revertedWith("There_Is_No_Such_Parent")
        })
    })

    describe("ageCalc", function () {

        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
        })
        it("release time is true", async () => {
            await interFi.addChild(child2.address, secondReleaseTime, childName)
            expect(await interFi.ageCalc(child2.address)).to.be.equal(true)
        })
        it("release time is false", async () => {
            expect(await interFi.ageCalc(child1.address)).to.be.equal(false)
        })
    })

    describe("fund", function () {

        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
        })

        it("funded the child succesfully", async () => {

            await interFi.fund(child1.address, { value: sendValue })
            expect(await interFi.getAmount(child1.address)).to.equal(sendValue)
        })
        it("Can't fund because there is no such parent", async () => {
            parent = notParent
            const response = await interFi.fund(child1.address)
            expect(response).to.be.revertedWith("There_Is_No_Such_Parent")
        })
        it("Can't fund because there is no such child", async () => {
            const response = await interFi.fund(child2.address)
            expect(response).to.be.reverted
        })
    })

    describe("withdrawParent", function () {

        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
        })

        it("withdraw parent succesfully", async () => {
            await interFi.fund(child1.address, { value: sendValue })
            const response = await interFi.withdrawParent(child1.address, withdrawValue)
            expect(await interFi.getAmount(child1.address)).to.equal(withdrawValue)
        })
        it("withdraw parent gives error due to no parent", async () => {
            parent = notParent
            const response = await interFi.withdrawParent(child1.address, withdrawValue)
            expect(response).to.be.revertedWith("There_Is_No_Such_Parent")
        })
        it("withdraw parent gives error due to no child", async () => {
            interFi.connect(parent)
            await interFi.addParent(parentName)
            const response = await interFi.withdrawParent(notParentChild.address, _amountToDraw)
            expect(response).to.be.revertedWith("There_Is_No_Such_Child")
        })

        it("withdraw parent gives error due to not enough amount", async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
            // call fund to give amount to the child first to make sure it is not enough to withdraw
            await interFi.fund(child1.address, _notEnoughAmount)
            const response = await interFi.withdrawParent(child1.address, _amountToDraw)
            expect(response).to.be.revertedWith("Not_Enough_Amount")
        })

    })
})