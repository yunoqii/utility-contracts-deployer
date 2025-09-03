// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20Airdroper - Airdrop utility contract for ERC20 tokens
/// @author yunoqii
/// @notice This contract allows the owner to airdrop ERC20 tokens to multiple addresses.
/// @dev Inherits from AbstractUtilityContract and Ownable
contract ERC20Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Initializes Ownable with deployer
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of addresses that can be airdropped in a single batch
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC20 token to airdrop
    IERC20 public token;

    /// @notice Amount of tokens to airdrop to each address  
    uint256 public amount;

    /// @notice Address holding tokens to be distributed    
    address public treasury;

    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Reverts if contract already initialized
    error AlreadyInitialized();
    /// @dev Reverts if receivers and amounts array lengths mismatch
    error ArraysLengthMismatch();
    /// @dev Reverts if insufficient token allowance from treasury
    error NotEnoughApprovedTokens();
    /// @dev Reverts if ERC20 transfer fails
    error TransferFailed();
    /// @dev Reverts if batch size exceeds the maximum allowed size
    error BatchSizeExceeded();

    // ------------------------------------------------------------------------
    // Modifiers
    // ------------------------------------------------------------------------

    /// @dev Reverts if contract already initialized
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }


    /// @notice Bool - true if contract is initialized.    
    bool private initialized;


    /// @notice Airdrops the tokens among addresses
    /// @param receivers List of addresses to receive tokens
    /// @param amounts List of token amounts to be airdropped
    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            require(token.transferFrom(treasuryAddress, receivers[i], amounts[i]), TransferFailed());
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Initializes the contract
    /// @param _initData Encoded initialization data
    /// @return true if initialization was successful
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, uint256 _amount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        setDeployManager(_deployManager);

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Encodes initialization data for the contract
    /// @param _deployManager Address of the deploy manager
    /// @param _token Address of the token
    /// @param _amount Amount of tokens to be distributed
    /// @param _treasury Address of the treasury
    /// @param _owner Address of the owner
    /// @return Encoded initialization data
    function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }
}

