// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VotingContract.sol";

contract VotingContractTest is Test {
    VotingContract votingContract;
    address owner;
    address nonOwner;
    address candidateAddress;
    address voterAddress;

    function setUp() public {
        owner = address(this); // Use the test contract's address as the owner
        nonOwner = address(2);
        candidateAddress = address(3);
        voterAddress = address(4);
        votingContract = new VotingContract();
        vm.startPrank(owner);
    }

    function testConstructor() public {
        address storedOwner = address(uint160(uint256(vm.load(address(votingContract), bytes32(uint256(0))))));
        assertEq(storedOwner, owner);
        bool electionStarted = vm.load(address(votingContract), bytes32(uint256(1))) == bytes32(uint256(1));
        assertFalse(electionStarted);
    }

    function testStartElection() public {
        votingContract.startElection();
        bool electionStarted = vm.load(address(votingContract), bytes32(uint256(1))) != bytes32(uint256(0));
        assertTrue(electionStarted);
    }
    
    function testFailStartElectionByNonOwner() public {
        vm.prank(nonOwner);
        vm.expectRevert("NotOwner");
        votingContract.startElection();
    }

    function testEndElection() public {
        votingContract.startElection();
        votingContract.endElection();
        bool electionStarted = vm.load(address(votingContract), bytes32(uint256(1))) != bytes32(uint256(0));
        assertFalse(electionStarted);
    }

    function testFailEndElectionByNonOwner() public {
        votingContract.startElection();
        vm.prank(nonOwner);
        vm.expectRevert("NotOwner");
        votingContract.endElection();
    }

    function testSetCandidate() public {
        votingContract.startElection();
        votingContract.setCandidate(candidateAddress, "Alice", 30, "image_url", "ipfs_hash");
        // Add verification logic here
    }

    function testFailSetCandidateBeforeElection() public {
        vm.expectRevert("ElectionNotStarted");
        votingContract.setCandidate(candidateAddress, "Alice", 30, "image_url", "ipfs_hash");
    }

    function testRegisterVoter() public {
        votingContract.startElection();
        votingContract.registerVoter(voterAddress, "Bob", "image_url", "ipfs_hash");
        // Add verification logic here
    }

    function testFailRegisterVoterBeforeElection() public {
        vm.expectRevert("ElectionNotStarted");
        votingContract.registerVoter(voterAddress, "Bob", "image_url", "ipfs_hash");
    }

    function testVote() public {
        votingContract.startElection();
        votingContract.registerVoter(voterAddress, "Bob", "image_url", "ipfs_hash");
        votingContract.setCandidate(candidateAddress, "Alice", 30, "image_url", "ipfs_hash");

        vm.prank(voterAddress);
        votingContract.vote(candidateAddress, 1); // Assuming candidate ID is 1
        // Add verification logic here
    }

    function testFailVoteBeforeElection() public {
        vm.expectRevert("ElectionNotStarted");
        vm.prank(voterAddress);
        votingContract.vote(candidateAddress, 1); // Assuming candidate ID is 1
    }

    function testFailVoteNonAuthorizedVoter() public {
        votingContract.startElection();
        vm.prank(nonOwner);
        vm.expectRevert("UnauthorizedVoter");
        votingContract.vote(candidateAddress, 1); // Assuming candidate ID is 1
    }
}
