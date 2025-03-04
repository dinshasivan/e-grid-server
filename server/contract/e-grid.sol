// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract EnergyAuction {
    
    enum UserType { Producer, Consumer, Prosumer }

    struct User {
        string userId;
        UserType userType;
        uint256 energyBalance;
    }

    struct Auction {
        address seller;
        uint256 energyAmount;
        uint256 minPrice; // minimum price per kWh
        address highestBidder; // address of the current highest bidder
        uint256 highestBid; // current highest bid amount
        bool active;
        uint256 endTime;
    }

    mapping(address => User) public users;
    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount; // total number of auctions created

    event UserRegistered(address indexed wallet, string userId, UserType userType, uint256 energyBalance);
    event AuctionCreated(uint256 auctionId, address indexed seller, uint256 energyAmount, uint256 minPrice, uint256 endTime);
    event BidPlaced(uint256 auctionId, address indexed bidder, uint256 bidAmount);
    event AuctionEnded(uint256 auctionId, address indexed winner, uint256 winningBid);

    modifier onlyRegistered() {
        require(bytes(users[msg.sender].userId).length > 0, "User not registered");
        _;
    }

    
    function registerUser(
        string memory _userId,
        UserType _userType,
        uint256 _energyBalance
    ) public {
        require(bytes(users[msg.sender].userId).length == 0, "User already registered");

        users[msg.sender] = User({
            userId: _userId,
            userType: _userType,
            energyBalance: _energyBalance
        });

        emit UserRegistered(msg.sender, _userId, _userType, _energyBalance);
    }

    
    function createAuction(uint256 _energyAmount, uint256 _minPrice, uint256 _duration) public onlyRegistered {
        require(users[msg.sender].energyBalance >= _energyAmount, "Insufficient energy balance");

        auctionCount++;
        auctions[auctionCount] = Auction({
            seller: msg.sender,
            energyAmount: _energyAmount,
            minPrice: _minPrice,
            highestBidder: address(0),
            highestBid: 0,
            active: true,
            endTime: block.timestamp + _duration
        });

        emit AuctionCreated(auctionCount, msg.sender, _energyAmount, _minPrice, block.timestamp + _duration);
    }

    
    function placeBid(uint256 _auctionId) public payable onlyRegistered {
        Auction storage auction = auctions[_auctionId];
        require(auction.active, "Auction is not active");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid && msg.value >= auction.minPrice, "Bid too low");

        // refund previous highest bidder
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;

        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    // auction end and transfer energy
    function endAuction(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.endTime, "Auction not yet ended");
        require(msg.sender == auction.seller, "Only seller can end auction");

        auction.active = false;

        if (auction.highestBidder != address(0)) {
            
            payable(auction.seller).transfer(auction.highestBid);

            // energy from seller and add to winner
            users[auction.seller].energyBalance -= auction.energyAmount;
            users[auction.highestBidder].energyBalance += auction.energyAmount;

            emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
        }
    }
}
