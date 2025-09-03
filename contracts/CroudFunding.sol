// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";

contract CroudFunding is Ownable {

    address public fundraiser;
    address public vestingContract;
    uint256 public amountGoal;
    uint256 public vestingTime;
    uint256 public amountRaised;
    mapping (address => uint256) public funders;
    bool fundingEnded = false;

    error AlreadyInitialized();
    error NothingToRefund();
    error TransferFailed();
    error FundingIsNotActive();
    error WidthrawNotAvailableWhileFunding();
    error VestingContractNotCreated();
    error NoFundsToWithdraw();

    event RefundSuccesful(address _to, uint256 _amount);
    event ParticipatingTaken(address _participater, uint256 _amount);
    event VestingCreated(address _vestingContract, uint256 _amount);

    constructor() Ownable(msg.sender) {}

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function contribute() external payable {
        require(!fundingEnded, FundingIsNotActive());

        funders[msg.sender] += msg.value;
        amountRaised += msg.value;

        emit ParticipatingTaken(msg.sender, msg.value);

        if (amountRaised >= amountGoal) {
            fundingEnding();
        }
    }

    function fundingEnding() internal {
        fundingEnded = true;

        RevenueVesting vesting = new RevenueVesting(
            fundraiser,
            uint64(block.timestamp),
            uint64(vestingTime)
        );

        vestingContract = address(vesting);

        (bool success, ) = payable(vesting).call{value: address(this).balance}("");
        require(success, TransferFailed());

        emit VestingCreated(address(vesting), address(vesting).balance);

    }

    function refund() external {
        require(funders[msg.sender] > 0, NothingToRefund());
        require(!fundingEnded, FundingIsNotActive());

        uint256 amountToRefund = funders[msg.sender];
        funders[msg.sender] = 0;
        amountRaised -= amountToRefund;
        (bool success, ) = msg.sender.call{value: amountToRefund}("");
        require(success, TransferFailed());

        emit RefundSuccesful(msg.sender, amountToRefund);
    }

    function initialize(bytes memory _initData) external notInitialized returns(bool) {

        (uint256 _amount, address _fundraiser, uint256 _vestingTime) = abi.decode(_initData, (uint256, address, uint256));

        amountGoal = _amount;
        fundraiser = _fundraiser;
        vestingTime = _vestingTime;

        Ownable.transferOwnership(_fundraiser);

        initialized = true;
        return true;
    }

    function getInitData(uint256 _amount, address _fundraiser, uint256 _vestingTime) external pure returns(bytes memory) {
        return abi.encode(_amount, _fundraiser, _vestingTime);
    }


}

contract RevenueVesting is VestingWallet {
    constructor(
        address beneficiary, 
        uint64 startTimestamp,      
        uint64 duration   
    )
        VestingWallet(beneficiary, startTimestamp, duration)
        payable
    {}
}