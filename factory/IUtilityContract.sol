// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUtilityContract {

    function initialize(bytes memory _initData) external returns (bool success); 

}