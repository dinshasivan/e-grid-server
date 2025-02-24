// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract EnergyTrading {
    
    struct User {
        string userId;
        string userType; // Producer, Consumer, Prosumer
        address walletAddress;
        uint256 energyBalance; // kWh
        uint256 availableEnergy; // kWh for trading
        uint256 tradingLimit; // Max kWh per trade
    }

    struct Trade {
        string transactionId;
        address seller;
        address buyer;
        uint256 energyAmount;
        uint256 totalCost;
        uint256 timestamp;
    }

    mapping(address => User) public users; // map for user
    mapping(string => Trade) public trades; // map for trade

    event UserRegistered(address indexed wallet, string userId, string userType, uint256 energyBalance, uint256 tradingLimit);
    event TradeExecuted(string transactionId, address indexed seller, address indexed buyer, uint256 energyAmount, uint256 totalCost, uint256 timestamp);

    // Register a new user
    function registerUser(
        string memory _userId,
        string memory _userType,
        uint256 _energyBalance,
        uint256 _availableEnergy,
        uint256 _tradingLimit
    ) public {
        require(users[msg.sender].walletAddress == address(0), "User already registered");

        users[msg.sender] = User({
            userId: _userId,
            userType: _userType,
            walletAddress: msg.sender,
            energyBalance: _energyBalance,
            availableEnergy: _availableEnergy,
            tradingLimit: _tradingLimit
        });

        emit UserRegistered(msg.sender, _userId, _userType, _energyBalance, _tradingLimit);
    }

    // Execute an energy trade
    function executeTrade(
        string memory _transactionId,
        address _buyer,
        uint256 _energyAmount,
        uint256 _totalCost
    ) public {
        require(users[msg.sender].walletAddress != address(0), "Seller not registered");
        require(users[_buyer].walletAddress != address(0), "Buyer not registered");
        require(users[msg.sender].availableEnergy >= _energyAmount, "Insufficient available energy");
        require(users[msg.sender].tradingLimit >= _energyAmount, "Exceeds trading limit");

        // Update balances
        users[msg.sender].availableEnergy -= _energyAmount;
        users[_buyer].energyBalance += _energyAmount;

        // Store trade details
        trades[_transactionId] = Trade({
            transactionId: _transactionId,
            seller: msg.sender,
            buyer: _buyer,
            energyAmount: _energyAmount,
            totalCost: _totalCost,
            timestamp: block.timestamp
        });

        emit TradeExecuted(_transactionId, msg.sender, _buyer, _energyAmount, _totalCost, block.timestamp);
    }

    // Get user details
    function getUser(address _userAddress) public view returns (User memory) {
        return users[_userAddress];
    }

    // Get trade details
    function getTrade(string memory _transactionId) public view returns (Trade memory) {
        return trades[_transactionId];
    }
}
