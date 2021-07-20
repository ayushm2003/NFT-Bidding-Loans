const { ethers } = require("hardhat");

async function deploy() {
	const [deployer] = await ethers.getSigners();

	const NFT = await ethers.getContractFactory("SampleERC721");
	console.log("got contrcact factory");
	const nft = await NFT.attach("0x3BF882716d01F998277FB8eDd21fFD42B1984373");
	console.log("attached address");
	await nft.awardItem(deployer.address, "www.example/xyz.json");

	console.log("Minted NFT");

	console.log("Deploying contracts with the account:", deployer.address);

	const LoanFactory = await ethers.getContractFactory("LoanFactory");
	const loanFactory = await LoanFactory.deploy();
	await loanFactory.deployed();

	console.log("LoanFactory address: ", loanFactory.address);

	//await loanFactory.requestLoan("0x3BF882716d01F998277FB8eDd21fFD42B1984373", 0, 1627181955);
  }

async function deployERC721() {
	const [deployer] = await ethers.getSigners();

	console.log("Deploying contracts with the account:", deployer.address);

	const Factory = await ethers.getContractFactory("SampleERC721");
	const contract = await Factory.deploy();
	await contract.deployed();

	console.log("ERC721 address: ", contract.address);
}

//deployERC721();
deploy();