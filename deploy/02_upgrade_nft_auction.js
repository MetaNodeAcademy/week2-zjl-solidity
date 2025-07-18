const { ethers, upgradese } = require("hardhat");
const fs = require("fs");
const path = require("path");
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();

    //读取.cache文件
    const storePath = paths.resolve(__dirname, "./.cache/proxyNftAuction.json");
    const storeData = fs.readFileSync(storePath, "utf-8");
    const { proxyAaaddress, implAddress, abi } = JSON.parse(storeData);
    //升级合约
    const nftAuction = await ethers.getContractFactory("NftAuction");
    //升级代理合约
    const nftAuctionProxyv2 = await upgradese.upgradeProxy(proxyAaaddress, nftAuction);
    await nftAuctionProxyv2.waitForDeployment();
    const proxyAaaddressv2 = await nftAuctionProxyv2.getAddress()
    console.log("nftAuctionProxyv2 address:", proxyAaaddressv2);

    //保存升级后的合约地址
    // fs.writeFileSync(storePath, JSON.stringify({
    //     proxyAaaddressv2,
    //     implAddress,
    //     abi: NftAuction.interface.format("json"),
    // }));
    await save("NftAuction", {
        abi,
        address: proxyAaaddressv2,
    });
}

module.exports.tars = ["upgradeNftAuction"]