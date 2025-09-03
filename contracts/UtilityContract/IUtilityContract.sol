// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/// @title IUtilityContract - Interface for utility contracts
/// @author yunoqii
/// @notice This interface defines the functions and events for utility contracts.
/// @dev Utility contracts should implement this interface to be compatible with the DeployManager.
interface IUtilityContract is IERC165 {
    // ------------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------------

    /// @dev Reverts if the deploy manager is not set or is invalid
    error DeployManagerCannotBeZero();

    /// @dev Reverts if the caller is not the deploy manager
    error NotDeployManager();

    /// @dev Reverts if DeployManager validation failed throw validateDeployManager()
    error FailedToValidateDeployManager();

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /// @notice Initializes the utility contract with the provided data
    /// @param _initData The initialization data for the utility contract
    /// @return True if the initialization was successful
    /// @dev This function should be called by the DeployManager after deploying the contract
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Returns the address of the DeployManager contract
    /// @return The address of the DeployManager contract
    function getDeployManager() external view returns (address);
}