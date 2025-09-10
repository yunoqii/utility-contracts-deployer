Utility Contracts Deployer
A collection of essential Solidity utility contracts for blockchain development.
Overview
This repository contains a curated set of utility smart contracts that are commonly needed across different blockchain projects. These contracts provide foundational functionality that can be reused and deployed across various EVM-compatible networks.
Contracts
Core Utility Contracts
The repository includes implementations of:

Multicall Contract: Batch multiple contract calls into a single transaction
Proxy Contracts: Minimal proxy implementations for gas-efficient contract deployment
Registry Contracts: On-chain registries for tracking contract addresses and metadata
Factory Contracts: Create2 factories for deterministic contract deployment
Access Control: Role-based access control utilities
Utility Libraries: Common helper functions and modifiers

Contract Features
Gas Optimized
All contracts are written with gas optimization in mind:

Minimal bytecode footprint
Efficient storage patterns
Optimized function selectors
Assembly optimizations where appropriate

Security Focused

Comprehensive input validation
Reentrancy protection where needed
Access control mechanisms
Well-tested edge cases

Standardized

Follows established patterns and conventions
Compatible with common tooling
Consistent interface design
Comprehensive documentation

Development
Prerequisites

Solidity ^0.8.0
Foundry or Hardhat for compilation and testing
