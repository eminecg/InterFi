const { Interface } = require("@ethersproject/abi")
const { assert, expect } = require("chai")
const { ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")


describe("InterFi", function () {
    let interFi
    let parent, child1, child2, notParent, notChild
    let parentName = "XX"
    let childName = "YY"
    let givenReleaseTime = 1723830394 // 2024-08-16
    let secondReleaseTime = 986371774 // 2001-04-04
    let sendValue = ethers.utils.parseEther("2")
    let withdrawValue = ethers.utils.parseEther("1")
    let biggerValue = ethers.utils.parseEther("2")

    //emine
    const initalBalance = ethers.utils.parseEther("0")
    const expectedValue = ethers.utils.parseEther("2")

    beforeEach(async () => {
        [parent, child1, child2, notParent, notChild] = await ethers.getSigners()
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
            parent = notParent
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
            await interFi.fund(child1.address, { value: sendValue })
        })

        it("withdrawParent succesfully", async () => {
            const response = await interFi.withdrawParent(child1.address, withdrawValue)
            expect(await interFi.getAmount(child1.address)).to.equal(withdrawValue)
        })
        it("withdrawParent gives error due to no parent", async () => {
            parent = notParent
            const response = await interFi.withdrawParent(child1.address, withdrawValue)
            expect(response).to.be.revertedWith("There_Is_No_Such_Parent")
        })
        it("withdrawParent gives error due to no child", async () => {
            const response = await interFi.withdrawParent(notChild.address, withdrawValue)
            expect(response).to.be.revertedWith("There_is_no_child_belongs_parent")
        })
        it("withdrawParent gives error due to not enough amount", async () => {
            // call fund to give amount to the child first to make sure it is not enough to withdraw
            const response = await interFi.withdrawParent(child1.address, biggerValue)
            expect(response).to.be.reverted
        })

    })

    describe("withdrawChild", function () {

        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
            await interFi.addChild(child2.address, secondReleaseTime, childName)
            await interFi.fund(child1.address, { value: sendValue })
            await interFi.fund(child2.address, { value: sendValue })

        })

        it("withdrawChild works succesfully", async () => {
            const response = await interFi.withdrawChild(child2.address, withdrawValue)
        })

        it("withdrawChild revert if there is no child", async () => {

            expect(await interFi.withdrawChild(notChild.address, 0))
                .to.be.revertedWith("There is no child with this address")
        })
        it("withdrawChild revert if there is not enough amount", async () => {
            const response = await interFi.withdrawChild(child1.address, biggerValue)
            expect(response)
                .to.be.reverted
        })
        it("withdrawChild revert if release time is not true", async () => {
            const response = await interFi.withdrawChild(child1.address, biggerValue)
            expect(response)
                .to.be.reverted
        })
    })



    describe("getOwner", function () {
        it("getOwner returns the correct address", async () => {
            const response = await interFi.getOwner()
            expect(response).to.be.equal(parent.address);
        }),
            it("getOwner returns the wrong address when calling from other account", async () => {
                const response = await interFi.connect(notParent).getOwner
                expect(response).to.not.be.equal(parent.address);

            })

    });
    // test for getBalance
    describe("getBalance", function () {
        it("getBalance returns the correct balance", async () => {     // aslında hatalı bigInt (00x)dönüyor     // not working well 
            const response = await interFi.getBalance()
            console.log("getBalance response: ")
            console.log(response);
            expect(response.toString()).to.be.equal(initalBalance);
        }),
            // should stop on modifier when calling from other account
            it("getBalance reverted on modifier when calling from other account", async () => { // working
                const response = await interFi.connect(notParent).getBalance
                expect(response).to.be.reverted
            }),
            // fund the contract to any address, check the balance 
            it("getBalance returns the correct balance after funding", async () => {      // not working well

                await interFi.addParent(parentName)
                await interFi.addChild(child1.address, givenReleaseTime, childName)
                await interFi.fund(child1.address, { value: sendValue })   // send 2 eth
                const response = await interFi.getBalance()
                expect(response.toString()).to.be.equal(expectedValue);  // expected 2 eth
            })
    }),

        // test for  getAmount 
        describe("getAmount", function () {
            it("getAmount returns the correct amount after fund the child account", async () => {
                // add parent and child
                await interFi.addParent(parentName)
                await interFi.addChild(child1.address, givenReleaseTime, childName)
                // fund the child
                await interFi.fund(child1.address, { value: sendValue })

                const response = await interFi.getAmount(child1.address)
                expect(response.toString()).to.be.equal(expectedValue);
            })

            it("getAmount returns the false amount after fund the child account", async () => {
                // add parent and child
                await interFi.addParent(parentName)
                await interFi.addChild(child2.address, givenReleaseTime, childName)

                // fund the child
                await interFi.fund(child1.address, { value: sendValue })
                await interFi.fund(child2.address, { value: 1 })

                const response = await interFi.getAmount(child2.address)
                expect(response.toString()).to.not.equal(expectedValue)
            })
        })

    // test for getRole
    describe("getRole", function () {
        it("getRole returns role for parent ", async () => {
            // add parent 
            await interFi.addParent(parentName)
            const response = await interFi.getRole()
            expect(response).to.be.equal("Parent");
        }),
            it("getRole returns role for child", async () => {

                await interFi.addParent(parentName)
                await interFi.addChild(child1.address, givenReleaseTime, childName)
                //parent = child1.address
                const response = await interFi.connect(child1).getRole()
                expect(response).to.be.equal("Child");
            }),
            it("getRole returns the role as unregistered ", async () => {
                const response = await interFi.connect(notParent).getRole()
                expect(response).to.be.equal("Unregistered");
            })

    })

    describe("getChild", function () {
        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
        })
        it("getChild from map succesfully", async () => {
            const response = await interFi.connect(child1).getChild()
            expect(response.name).to.be.equal("YY")
        })
        it("getChild from map revert with error", async () => {
            expect(await interFi.connect(notChild).getChild).to.be.reverted
        })
    })

    describe("getParent", function () {
        beforeEach(async () => {
            await interFi.addParent(parentName)
        })
        it("getParent from map succesfully", async () => {
            const response = await interFi.getParent()
            expect(response.name).to.be.equal("XX")
        })
        it("getParent from map revert with error", async () => {
            expect(await interFi.connect(notParent).getParent).to.be.reverted
        })
    })

    describe("getChildren", function () {

        beforeEach(async () => {
            await interFi.addParent(parentName)
            await interFi.addChild(child1.address, givenReleaseTime, childName)
            await interFi.addChild(child2.address, secondReleaseTime, childName)
        })

        it("getChildren returns the correct array", async () => {
            const response = await interFi.getChildren([])
            expect(response).to.be.an('array').that.length(2);
            expect(response[0]).to.be.equal(child1.address)
            expect(response[1]).to.be.equal(child2.address)

        }),

            it("getChildren returns the wrong array", async () => {
                child1 = notChild
                child2 = notChild
                const response = await interFi.getChildren([]);
                expect(response).to.be.an('array').that.length(2)
                expect(response[0]).to.not.equal(child1.address)
                expect(response[1]).to.not.equal(child2.address)
            })
    })
})


