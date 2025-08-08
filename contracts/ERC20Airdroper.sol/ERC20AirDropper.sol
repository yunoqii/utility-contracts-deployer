// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Airdroper is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}

    IERC20 public token;
    uint256 public amount;
    address public treasury;

    error AlreadyInitialized();
    error ArraysLengthMismatch();
    error NotEnoughApprovedTokens();
    error TransferFailed();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        for (uint256 i = 0; i < receivers.length; i++) {
            require(token.transferFrom(treasury, receivers[i], amounts[i]), TransferFailed());
        }

    }

    function initialize(bytes memory _initData) external notInitialized returns(bool) {

        (address _token, uint256 _amount, address _treasury, address _owner) = abi.decode(_initData, (address, uint256, address, address));

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    function getInitData(address _token, uint256 _amount, address _treasury, address _owner) external pure returns(bytes memory) {
        return abi.encode(_token, _amount, _treasury, _owner);
    }
    

}

//["0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C"]
//[250000,31000,19000,250000]