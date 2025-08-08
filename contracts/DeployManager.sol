// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IUtilityContract.sol";

contract DeployManager is Ownable {

    event NewContractAdded(address _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
    event ContractFeeUpdated(address _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
    event ContractStatusUpdated(address _contractAddess, bool _isActive, uint256 _timestamp);
    event NewDeployment(address _contractAddress, address _deployer, uint256 _fee, uint256 _timestamp);

    constructor() Ownable(msg.sender) {

    }

    struct ContractInfo{
        uint256 fee;
        bool isActive;
        uint256 registeredAt;
    }

    mapping(address => address[]) public deployedContracts;
    mapping(address => ContractInfo) public contractsData;

    error ContractNotActive();
    error NotEnoughFunds();
    error ContractNotRegistered();
    error InitializationFailed();

    function deploy(address _utilityContract, bytes calldata _initData) external payable returns(address) {
            
            ContractInfo memory info = contractsData[_utilityContract];

            require(info.isActive, ContractNotActive());
            require(msg.value >= info.fee, NotEnoughFunds());
            require(info.registeredAt > 0, ContractNotRegistered());

            address clone = Clones.clone(_utilityContract);

            require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

            
            payable(owner()).transfer(msg.value);

    	    deployedContracts[msg.sender].push(clone);

            emit NewDeployment(clone, msg.sender, msg.value, block.timestamp);

            return clone;
    }

    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external onlyOwner {
        contractsData[_contractAddress] = ContractInfo({
            fee: _fee,
            isActive: _isActive,
            registeredAt: block.timestamp
        });

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    function setFee(address _contractAddress, uint256 _newFee) external onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractNotRegistered());

        uint256 oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, oldFee, _newFee, block.timestamp);
    }

    function deactivate(address _contractAddress) external onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractNotRegistered());
        contractsData[_contractAddress].isActive = false;

        emit ContractStatusUpdated(_contractAddress, false, block.timestamp);
    }

    function activate(address _contractAddress) external onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractNotRegistered());
        contractsData[_contractAddress].isActive = true;

        emit ContractStatusUpdated(_contractAddress, true, block.timestamp);
    }    

}