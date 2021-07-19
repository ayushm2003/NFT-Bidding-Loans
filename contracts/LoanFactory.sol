pragma soliity ^0.8.0;

import "./Loan.sol";

contract LoanFactory {

    event LoanCreated(address loaner, address nftContract, uint nftId, uint duration);
    function requestLoan(address _nftContract, uint _nftId, uint _duration) external {
        require(duration > block.timestamp, "Loans cannot be settled in the past. Well, unless you are Edgar");
        Loan loan = new Loan(msg.sender, _nftContract, _nftId);

        emit LoanCreated(msg.sender, _nftContract, _nftId, _duration);
    }
}