// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Initializes Ownable with deployer
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of addresses that can be airdropped in a single batch    
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 10;

    /// @notice Address of token to AirDrop
    IERC1155 public token;

    /// @notice Address of treasury to send tokens from
    address public treasury;

    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @notice Reverts if contract is already initialized
    error AlreadyInitialized();
    /// @notice Reverts if recievers and tokenIds arrays length mismatch
    error ReceiversLengthMismatch();
    /// @notice Reverts if amounts and tokenIds arrays length mismatch
    error AmountsLengthMismatch();
    /// @notice Reverts if batch size exceeds maximum allowed batch size
    error BatchSizeExceeded();
    /// @notice Reverts if token to AirDrop are not approved
    error NeedToApproveTokens();

    /// @dev Reverts if contract already initialized
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @notice Bool - true if contract is initialized.
    bool private initialized;

    /// @notice Airdrop tokens to receivers. Only owner can call this function.
    /// @param receivers Array of receivers addresses.
    /// @param amounts Array of amounts to send.
    /// @param tokenIds Array of tokenIds to send.
    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
        external
        onlyOwner
    {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ReceiversLengthMismatch());
        require(amounts.length == tokenIds.length, AmountsLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < amounts.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i], amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Initialize contract. Only deploy manager can call this function.
    /// @param _initData Encoded initialization data.
    /// @return Bool - true if initialization is successful.
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC1155(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Get encoded initialization data.
    /// @param _deployManager Address of deploy manager.
    /// @param _token Address of token.
    /// @param _treasury Address of treasury.
    /// @param _owner Address of owner.
    /// @return Encoded initialization data.
    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}