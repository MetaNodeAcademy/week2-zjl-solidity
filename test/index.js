const { ethers } = require("hardhat");
describe("Starting", async function () {
    it("Should return the new greeting once it's changed", async function () {
        const Contranct = await ethers.getContractFactory("NftAuction");
        const contract = await Contranct.deploy();
        await contract.waitForDeployment();

        await contract.createAuction(
            100 * 1000,
            ethers.parseEther("0.00000000000000001"),
            ethers.ZeroAddress,
            1
        )
        const auction = await contract.auctions(0);
        console.log(auction)

    })
})