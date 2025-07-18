// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    mapping(uint256 => string) private tokenURIs;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    // function _baseURI() internal view virtual override returns (string memory) {
    //     return "https://your-metadata-server.com/metadata/"; // 可选：设置基础URI，实际URI将在tokenURIs中覆盖
    // }

    function mintNFT(address recipient, string memory tokenURI) public onlyOwner {
        _safeMint(recipient, nextTokenId);
        tokenURIs[nextTokenId] = tokenURI;
        nextTokenId++;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return tokenURIs[tokenId];
    }
}