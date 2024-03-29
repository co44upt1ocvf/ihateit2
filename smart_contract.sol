// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Control {
    struct User {
        uint256 balance;
    }

    struct Estate {
        address owner;
        bool isActive;
        string date;
        string estateType;
    }

    struct Ad {
        address owner;
        uint256 price;
        uint256 estateId;
        bool isOpen;
    }

    mapping(address => User) private users;
    mapping(uint256 => Estate) private estates;
    mapping(uint256 => Ad) private ads;
    uint256 private nextEstateId = 1;
    uint256 private nextAdId = 1;

    event NewBalance(address user, uint256 amount);
    event EstateCreated(address owner, uint256 estateId, string date, string estateType);
    event AdCreated(address owner, uint256 estateId, uint256 adId, string date, uint256 price);
    event EstateUpdated(address owner, uint256 estateId, string date, bool isActive);
    event AdUpdated(address owner, uint256 estateId, uint256 adId, string date, bool isOpen);
    event EstatePurchased(address owner, address buyer, uint256 adId, uint256 estateId, bool isOpen, string date, uint256 price);
    event FundsSent(address receiver, uint256 amount, string date);

    function accountStatus() public payable {
        require(msg.value > 0, "Enter a value greater than");
        users[msg.sender].balance += msg.value;
        emit NewBalance(msg.sender, msg.value);
    }

    function createEstate(string memory _date, string memory _estateType) public {
        estates[nextEstateId] = Estate(msg.sender, true, _date, _estateType);
        emit EstateCreated(msg.sender, nextEstateId, _date, _estateType);
        nextEstateId++;
    }

    function createAd(uint256 _estateId, string memory _date, uint256 _price) public {
        require(estates[_estateId].owner == msg.sender, "You are not the owner of the property");
        require(estates[_estateId].isActive, "Property is not active");
        ads[nextAdId] = Ad(msg.sender, _price, _estateId, true);
        emit AdCreated(msg.sender, _estateId, nextAdId, _date, _price);
        nextAdId++;
    }

    function updateEstateStatus(uint256 _estateId, bool _isActive) public {
        require(estates[_estateId].owner == msg.sender, "You are not the owner of the property");
        estates[_estateId].isActive = _isActive;
        emit EstateUpdated(msg.sender, _estateId, uint2str(block.timestamp), _isActive);
    }

    function updateAdStatus(uint256 _adId, bool _isOpen) public {
        require(ads[_adId].owner == msg.sender, "You are not the owner of the ad");
        ads[_adId].isOpen = _isOpen;
        emit AdUpdated(msg.sender, ads[_adId].estateId, _adId, uint2str(block.timestamp), _isOpen);
    }

    function removal(uint256 _amount) public {
        require(_amount > 0 && _amount <= users[msg.sender].balance, "Insufficient funds");
        payable(msg.sender).transfer(_amount);
        users[msg.sender].balance -= _amount;
        emit FundsSent(msg.sender, _amount, uint2str(block.timestamp));
    }

    function getBalance() public view returns (uint256) {
        return users[msg.sender].balance;
    }

    function getEstate(uint256 _estateId) public view returns (Estate memory) {
        return estates[_estateId];
    }

    function getAd(uint256 _adId) public view returns (Ad memory) {
        return ads[_adId];
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}