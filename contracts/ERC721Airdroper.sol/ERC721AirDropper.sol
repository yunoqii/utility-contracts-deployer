// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Airdroper is AbstractUtilityContract, Ownable {
    /// @notice Initializes Ownable with deployer
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum number of addresses that can be airdropped in a single batch   
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC721 token contract address
    IERC721 public token;

    /// @notice Treasury address that holds all tokens to be airdropped
    address public treasury;

    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @notice Reverts if trying to initialize an already initialized contract
    error AlreadyInitialized();
    /// @notice Reverts if the length of the arrays passed in is not the same
    error ArraysLengthMismatch();
    /// @notice Reverts if treasury is not approved to transfer tokens
    error NeedToApproveTokens();
    /// @notice Reverts if batch size is exceeded
    error BatchSizeExceeded();

    /// @dev Reverts if contract already initialized
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @notice Bool - true if contract is initialized.
    bool private initialized;

    /// @notice Airdrop tokens to receivers
    /// @param receivers array of addresses to receive tokens
    /// @param tokenIds array of tokenIds to be sent to receivers
    function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ArraysLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < tokenIds.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i]);
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

        token = IERC721(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Get initialization data.
    /// @param _deployManager The deploy manager address.
    /// @param _token The token address.
    /// @param _treasury The treasury address.
    /// @param _owner The owner address.
    /// @return Bytes - encoded initialization data.
    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}