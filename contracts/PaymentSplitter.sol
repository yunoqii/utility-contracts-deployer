// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract RevenueSplitter is VestingWallet {

    constructor(address[] memory payees_, uint256[] memory shares_) PaymentSplitter(payees_, shares_) payable {}
}