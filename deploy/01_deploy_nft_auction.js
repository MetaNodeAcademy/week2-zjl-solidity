const { deployments, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();

    const NftAuction = await ethers.getContractFactory("NftAuction");
    const nftAuctionProxy = await upgrades.deployProxy(NftAuction, [], {
        initializer: "initialize",
    });
    await nftAuctionProxy.waitForDeployment();
    const proxyAaaddress = await nftAuctionProxy.getAddress();
    const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAaaddress);
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json");
    fs.writeFileSync(storePath, JSON.stringify({
        proxyAaaddress,
        implAddress,
        abi: NftAuction.interface.format("json"),
    }));
    await save("NftAuction", {
        address: proxyAaaddress,
        abi: NftAuction.interface.format("json"),
    });
}
module.exports.tags = ["depolyNftAuction"];