// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract NftAuction is Initializable {
    //结构体
    struct Auction {
        //卖家
        address seller;
        //拍卖持续时间
        uint256 duration;
        //起始价格
        uint256 startPrice;
        //开始时间
        uint256 startTime;
        //是否结束
        bool ended;
        //最高出价者
        address highestBidder;
        //最高价格
        uint256 highestBid;
        //NFT合约地址
        address nftContract;
        //NFT ID
        uint256 tokenId;
        address token;
    }

    //状态变量
    mapping(uint256 => Auction) public auctions;
    //下一个拍卖ID
    uint256 public nextAuctionId;
    //管理员地址
    address public admin;
    //喂价
    mapping(address => AggregatorV3Interface) public feedPrice;

    function initialize() initializer public {
        admin = msg.sender;
    }
    //设置到预言机获取喂价
    function setFeedPrice(address _nftContract, address _feedPrice) public {
        feedPrice[_nftContract] = AggregatorV3Interface(_feedPrice);
    }

    //获取当前价格
    function getCurrentPrice(address _nftContract) public view returns (int) {
        AggregatorV3Interface feed = feedPrice[_nftContract];
        (, int256 price, , ,) = feed.latestRoundData();
        return price;
    }
    

    //创建拍卖
    function createAuction(uint256 _duration, uint256 _startPrice, address _nftContract, uint256 _tokenId) public {
        //只有管理员可以创建拍卖
        require(msg.sender == admin, "only admin can create auctions");
        require(_duration > 1000*60, "Duration must be greater than 0");
        require(_startPrice > 0, "start price must be greater than 0");

        IERC721(_nftContract).approve(address(this), _tokenId);
        auctions[nextAuctionId]=Auction({
            seller: msg.sender,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp,
            nftContract: _nftContract,
            tokenId: _tokenId
        });

        nextAuctionId++;
    }

    //出价
    function placBid(uint256 _auctionId,uint256 amount,address _nftContract) external payable {
        Auction storage auction = auctions[_auctionId];
       
        //拍卖必须未结束
        require(!auction.ended&&auction.startTime+auction.duration>block.timestamp, "auction has ended");
        //出价必须大于当前最高价
        require(msg.value > auction.highestBid&&msg.value >=auction.startPrice, "bid must be higher than current highest bid");
        
        if(_nftContract!=address[0]){
           uint erc20Value=amount*uint(getCurrentPrice(_nftContract));
           uint startPrice=auction.startPrice*uint(getCurrentPrice(auction.token));
           uint highestBidder=auction.highestBid*uint(getCurrentPrice(auction.token));
           
        }

    
        //如果当前最高出价者不为空，则退还其出价
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        //更新最高出价者和最高出价
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];

        //拍卖必须未结束
        require(!auction.ended&&auction.startTime+auction.duration<block.timestamp, "auction has not ended");

        //将NFT转移给最高出价者
        IERC721(auction.nftContract).safeTransferFrom(admin, auction.highestBidder, auction.tokenId);

        //将拍卖标记为已结束
        auction.ended = true;

        //将拍卖的起始价格退还给卖家
        // payable(address(this)).transfer(address(this).balance);
        payable(auction.seller).transfer(auction.highestBid);
    }

}
