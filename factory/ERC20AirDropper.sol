// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUtilityContract.sol";

contract ERC20Airdropper {
    // ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
    // [20000000000000000000000, 30000000000000000000000, 10000000000000000000000]

    error AlreadyInitialized();

    bool private initialized;
    IERC20 public token;
    uint256 public amount;
    address public tokenAddress;

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }


    function initialize(bytes memory _initData) external notInitialized returns (bool) {
        (tokenAddress, amount) = abi.decode(_initData, (address, uint256));
        token = IERC20(tokenAddress);
        initialized = true;

        return true;
    }

    function getInitData(address _tokenAddress, uint256 _airdropAmount) external pure returns (bytes memory) {
      return abi.encode(_tokenAddress, _airdropAmount);
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external {
        require(receivers.length == amounts.length, "Arrays length missmatch");
        require(token.allowance(msg.sender, address(this)) >= amount, "Not enough approved tokens");

        for (uint256 i = 0; i < amounts.length; i++) {
            require(token.transferFrom(msg.sender, receivers[i], amounts[i]), "Transfer failed");
        }

    }

}