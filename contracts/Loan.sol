pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Loan is IERC721Receiver {

    // The address of the loan recipient
    address payable public immutable owner;
    address public immutable nftContract;
    uint256 public immutable nftId;
    // The duration of loan specified by the loan recipient
    uint public immutable duration;
    // The fees in percentage that the owner is willing to pay to bidder in case loan is repaid in full
    uint public immutable fee;

    // Toggled when contract holds NFT
    bool public nftOwned;
    // Current Highest bid
    uint public highestBid = 0;
    // Current highest bidder
    address payable public highestBidder;
    // Amount of loan paid back
    uint public amtRepaid = 0;
    // Toggled when loan is fully paid back or recepient is no longer in need of higher bids
    bool public acceptingBids = false;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // EVENTS
    // Address of new highest bidder and the amount
    event NewHighestBid(address _bidder, uint256 _amount);

    constructor(address _owner, address _nftContract, uint _nftId, uint _duration, uint _fee) public {
        owner = payable(_owner);
        nftContract = _nftContract;
        nftId = _nftId;
        duration = _duration;
        fee = _fee;
    }

    /// @notice Lets people bid on the NFT. The highest bid's amount is transferred to the owner
    function provideLoan() public payable {
        require(acceptingBids, "Currently not accepting bids");
        require(nftOwned, "Contract not in contol of the NFT");
        // Bids lower than the current highest bid are ignored
        require(msg.value > highestBid, "Loan amount less than the one already provided");

        // Logic for the first bidder
        if (highestBidder == address(0)) {
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
            // Transfer the amount to the owner
            owner.transfer(msg.value);
        }
        // From 2nd highest bidder onwards
        else {
            // Transfer the amount of the previous bid to the previously highest bidder
            highestBidder.transfer(highestBid);
            // Tranfer the remaining amount to the owner
            owner.transfer(msg.value - highestBid);
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
        }

        emit NewHighestBid(msg.sender, msg.value);
    }

    /// @notice Let's the owner repay the loan
    function repayLoan() public payable {
        require(nftOwned == true, "No loan was taken");
        require(amtRepaid < highestBid, "Loan already repaid");
        amtRepaid += msg.value;
    }

    /// @notice To be called when duration of the loan has expired. 2 possible scenarios - 
    ///         1. The owner repays the loan and gets the nft back, and he amout is transferred to the highest bidder
    ///         2. The owner does not repay the loan and the nft is transferred to the highest bidder 
    ///            and any amt. repaid by owner is transferred back to the owner
    function liquidate() public {
        require(nftOwned == true, "No loan was taken");
        require(duration < block.timestamp, "Loan still valid");

        // If the owner has not repaid the loan, transfer the nft to the highest bidder
        if (amtRepaid < highestBid) {
            // Transfer NFT to highestBidder
            IERC721(nftContract).safeTransferFrom(address(this), highestBidder, nftId);
            nftOwned = false;
            // Transfer loan repaid amount to owner
            owner.transfer(amtRepaid);
            
            acceptingBids = false;
        }
        // If the owner has repaid the loan, transfer the loan amount to the owner
        else {
            // Transfer NFT to owner
            IERC721(nftContract).safeTransferFrom(address(this), owner, nftId);
            nftOwned = false;
            // Transfer loan amount to highestBidder
            highestBidder.transfer(amtRepaid);

            acceptingBids = false;
        }
    }

    function stopAcceptingBids() public onlyOwner {
        acceptingBids = false;
    }

    function startAcceptingBids() public onlyOwner {
        require(acceptingBids == false, "Already accepting bids");
        require(nftOwned == true, "Not in control of NFT");
        acceptingBids = true;
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == nftContract, "Incorrect NFT contract");
        require(tokenId == nftId, "Incorrect NFT ID");
        require(IERC721(nftContract).ownerOf(tokenId) == address(this), "Did not tranfer the NFT");

        nftOwned = true;

        acceptingBids = true;

        return 0x150b7a02;
    }
}