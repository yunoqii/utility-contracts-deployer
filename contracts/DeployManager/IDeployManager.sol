// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IDeployManager - Factory for utility contracts
/// @author yunoqii
/// @notice This interface defines the functions, errors and events for the DeployManager contract.
interface IDeployManager is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Reverts if the contract is not active
    error ContractNotActive();

    /// @dev Not enough funds to deploy the contract
    error NotEnoughtFunds();

    /// @dev Reverts if the contract is not registered
    error ContractDoesNotRegistered();

    /// @dev Reverts if the .initialize() function fails
    error InitializationFailed();

    /// @dev Reverts if the contract is not a utility contract
    error ContractIsNotUtilityContract();

    /// @dev Reverts if trying to register a contract what already exists
    error AlreadyRegistered();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emitted when a new utility contract template is registered.
    /// @param _contractAddress Address of the registered utility contract template.
    /// @param _fee Fee (in wei) required to deploy a clone of this contract.
    /// @param _isActive Whether the contract is active and deployable.
    /// @param _timestamp Timestamp when the contract was added.
    event NewContractAdded(address indexed _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp); 

    /// @notice Emmited when a fee for deploy updated
    /// @param _contractAddress Address of the contract for which the fee was updated.
    /// @param _oldFee Old fee (in wei) for deploying the contract.
    /// @param _newFee New fee (in wei) for deploying the contract.
    /// @param _timestamp Timestamp when the fee was updated.
    event ContractFeeUpdated(address indexed _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);

    /// @notice Emmited when a contract status was updated
    /// @param _contractAddress Address of the contract for which the status was updated.
    /// @param _isActive New status of the contract.
    /// @param _timestamp Timestamp when the status was updated.
    event ContractStatusUpdated(address indexed _contractAddress, bool _isActive, uint256 _timestamp);

    /// @notice Emmited when a new contract was deployed.
    /// @param _deployer Address of the deployer.
    /// @param _contractAddress Address of the deployed contract.
    /// @param _fee Fee (in wei) used for deploy.
    /// @param _timestamp Timestamp when the contract was deployed.
    event NewDeployment(address indexed _deployer, address indexed _contractAddress, uint256 _fee, uint256 _timestamp);

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Deploys a new utility contract
    /// @param _utilityContract The address of the utility contract template
    /// @param _initData The initialization data for the utility contract
    /// @return The address of the deployed utility contract
    /// @dev Emits NewDeployment event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Adds a new contract to the list to deploy.
    /// @param _contractAddress The address of the contract to add.
    /// @param _fee The fee (in wei) for deploying the contract.
    /// @param _isActive True if the contract can be deployed immediately.
    /// @dev Only the owner can call this function.
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updates the fee for deploying the contract.
    /// @param _contractAddress The address of the contract to update.
    /// @param _newFee The new fee (in wei) for deploying the contract.
    /// @dev Only the owner can call this function.
    function updateFee(address _contractAddress, uint256 _newFee) external;

    /// @notice Deactivates a contract. Only the owner can call this function.
    /// @param _contractAddress The address of the contract to deactivate.
    /// @dev Sets _isActive to false
    function deactivateContract(address _contractAddress) external;

    /// @notice Activates a contract. Only the owner can call this function.
    /// @param _contractAddress The address of the contract to activate.
    /// @dev Sets _isActive to true 
    function activateContract(address _contractAddress) external;
}