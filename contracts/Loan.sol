pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Loan is IERC721Receiver {

    address payable public immutable owner;
    address public immutable nftContract;
    uint256 public immutable nftId;
    uint public immutable duration;

    bool public nftOwned;

    uint public highestBid = 0;
    address payable public highestBidder;

    uint public amtRepaid = 0;

    bool public acceptingBids = false;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // EVENTS
    event NewHighestBid(address _bidder, uint256 _amount);

    constructor(address _owner, address _nftContract, uint _nftId, uint _duration) public {
        owner = payable(_owner);
        nftContract = _nftContract;
        nftId = _nftId;
        duration = _duration;
    }


    function provideLoan() public payable {
        require(acceptingBids, "Currently not accepting bids");
        require(nftOwned == true, "Contract not in contol of the NFT");
        require(msg.value > highestBid, "Loan amount less than the one already provided");
        if (highestBidder == address(0)) {
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
            owner.transfer(msg.value);
        }
        else {
            highestBidder.transfer(highestBid);
            highestBid = msg.value;
            highestBidder = payable(msg.sender);
            owner.transfer(msg.value);
        }
        emit NewHighestBid(msg.sender, msg.value);
    }

    function repayLoan() public payable {
        require(nftOwned == true, "No loan was taken");
        require(amtRepaid < highestBid, "Loan already repaid");
        amtRepaid += msg.value;
    }

    function liquidate() public {
        require(nftOwned == true, "No loan was taken");
        require(duration < block.timestamp, "Loan still valid");

        if (amtRepaid < highestBid) {
            // Transfer NFT to highestBidder
            IERC721(nftContract).safeTransferFrom(address(this), highestBidder, nftId);
            nftOwned = false;
            // Transfer loan repaid amount to owner
            owner.transfer(amtRepaid);
            
            acceptingBids = false;
        }
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
        require(from == nftContract, "Incorrect NFT contract");
        require(tokenId == nftId, "Incorrect NFT ID");

        nftOwned = true;

        acceptingBids = true;

        return 0x150b7a02;
    }
}