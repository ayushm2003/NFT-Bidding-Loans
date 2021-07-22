pragma solidity ^0.8.0;

import "./Loan.sol";

contract LoanFactory {

    event LoanCreated(address owner, address nftContract, uint nftId, uint duration, uint fee);
    function requestLoan(address _nftContract, uint _nftId, uint _duration, uint _feePercentage) external {
        require(_duration > block.timestamp, "Loans cannot be settled in the past. Well, unless you are Edgar");
        Loan loan = new Loan(msg.sender, _nftContract, _nftId, _duration, _feePercentage);

        emit LoanCreated(msg.sender, _nftContract, _nftId, _duration, _feePercentage);
    }
}