// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "ds-test/test.sol";
import "../src/VotingContract.sol";  

contract VotingContractTest {
    VotingContract private votingContract;

    // Deploy a new VotingContract for each test
    function beforeEach() public {
        votingContract = new VotingContract();
    }

    // Test that the owner of the contract is the deployer
    function testOwnerIsDeployer() public {
        address owner = votingContract.owner();
        Assert.equal(owner, address(this), "Owner should be the deployer");
    }

    // Test candidate registration functionality
    function testCandidateRegistration() public {
        string memory name = "Candidate 1";
        uint8 age = 30;
        string memory image = "https://example.com/image1.jpg";
        string memory ipfs = "Qm123456789"; // Example IPFS hash

        votingContract.setCandidate(address(this), name, age, image, ipfs);

        (string memory retrievedName, uint8 retrievedAge, string memory retrievedImage, uint256 voteCount, string memory retrievedIpfs) = votingContract.getCandidateData(address(this));

        Assert.equal(retrievedName, name, "Candidate name should match");
        Assert.equal(retrievedAge, age, "Candidate age should match");
        Assert.equal(retrievedImage, image, "Candidate image should match");
        Assert.equal(retrievedIpfs, ipfs, "Candidate IPFS should match");
    }

    // Test voter registration functionality
    function testVoterRegistration() public {
        string memory name = "Voter 1";
        string memory image = "https://example.com/voter1.jpg";
        string memory ipfs = "Qm987654321"; // Example IPFS hash

        votingContract.registerVoter(address(this), name, image, ipfs);

        (uint256 retrievedId, string memory retrievedName, string memory retrievedImage, uint256 allowed, bool voted, uint256 voterVote, string memory retrievedIpfs) = votingContract.getVoterData(address(this));

        Assert.equal(retrievedName, name, "Voter name should match");
        Assert.equal(retrievedImage, image, "Voter image should match");
        Assert.equal(allowed, 1, "Voter should be allowed");
        Assert.equal(voted, false, "Voter should not have voted");
        Assert.equal(voterVote, 0, "Voter's vote should be 0");
        Assert.equal(retrievedIpfs, ipfs, "Voter IPFS should match");
    }

    // Test the voting functionality
    function testVoting() public {
        // Register a candidate
        string memory candidateName = "Candidate 2";
        uint8 candidateAge = 35;
        string memory candidateImage = "https://example.com/image2.jpg";
        string memory candidateIpfs = "Qm987654322"; // Example IPFS hash
        votingContract.setCandidate(address(0x1), candidateName, candidateAge, candidateImage, candidateIpfs);

        // Register a voter
        string memory voterName = "Voter 2";
        string memory voterImage = "https://example.com/voter2.jpg";
        string memory voterIpfs = "Qm987654323"; // Example IPFS hash
        votingContract.registerVoter(address(0x2), voterName, voterImage, voterIpfs);

        // Vote
        votingContract.vote(address(0x1), 1);

        uint256 voteCount = votingContract.getVoteCount(address(0x1));
        (, , , , , uint256 voterVote, ) = votingContract.getVoterData(address(0x2));

        Assert.equal(voteCount, 1, "Vote count should be incremented");
        Assert.equal(voterVote, 1, "Voter's vote should match the candidate's ID");
    }
}
