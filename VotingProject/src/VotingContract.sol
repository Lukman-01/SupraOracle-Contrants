// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VotingContract
 * @dev A smart contract for managing candidates and voters in an election.
 * This contract allows for the registration of candidates and voters, and enables voting in the election.
 */
contract VotingContract {
    address private _owner;

    /**
     * @dev Sets the original `_owner` of the contract to the sender
     * account. Initializes voter and candidate IDs to 1.
     */
    constructor() {
        _owner = msg.sender;
        _voterId._value = 1; // Starting from 1
        _candidateId._value = 1; // Starting from 1
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    struct Counter {
        uint256 _value;
    }

    Counter private _voterId;
    Counter private _candidateId;

    function increment(Counter storage counter) private {
        counter._value += 1;
    }

    function current(Counter storage counter) private view returns (uint256) {
        return counter._value;
    }

    struct Candidate {
        uint256 candidateId;
        string name;
        uint8 age;
        string image;
        uint256 voteCount;
        address _address;
        string ipfs;
    }

    mapping(address => Candidate) private candidates;
    address[] private candidateAddresses;

    event CandidateCreated(uint256 indexed candidateId, string name, uint8 age, string image, uint256 voteCount, address _address, string ipfs);

    struct Voter {
        uint256 voterId;
        string name;
        string image;
        uint256 allowed;
        bool voted;
        uint256 voterVote;
        string ipfs;
    }

    mapping(address => Voter) private voters;
    address[] private votedVoters;
    address[] private voterAddresses;

    event VoterCreated(uint256 indexed voterId, string name, string image, uint256 allowed, bool voted, uint256 voterVote, string ipfs);

    /**
     * @dev Registers a new candidate. Can only be called by the contract owner.
     * @param _add The Ethereum address of the candidate to register.
     * @param _name The name of the candidate.
     * @param _age The age of the candidate.
     * @param _image The image URL of the candidate.
     * @param _ipfs The IPFS hash of additional candidate information.
     */
    function setCandidate(address _add, string memory _name, uint8 _age, string memory _image, string memory _ipfs) external onlyOwner {
        increment(_candidateId);
        uint256 idNumber = current(_candidateId);

        Candidate storage candidate = candidates[_add];
        candidate.candidateId = idNumber;
        candidate.name = _name;
        candidate.age = _age;
        candidate.image = _image;
        candidate.voteCount = 0;
        candidate._address = _add;
        candidate.ipfs = _ipfs;

        candidateAddresses.push(_add);

        emit CandidateCreated(idNumber, _name, _age, _image, 0, _add, _ipfs);
    }

    /**
     * @dev Returns the addresses of all registered candidates.
     * @return An array of candidate addresses.
     */
    function getCandidateAddresses() external view returns (address[] memory) {
        return candidateAddresses;
    }

    /**
     * @dev Returns the data of a specific candidate by their address.
     * @param _candidateAddress The Ethereum address of the candidate.
     * @return name The name of the candidate.
     * @return age The age of the candidate.
     * @return image The image URL of the candidate.
     * @return voteCount The current vote count of the candidate.
     * @return ipfs The IPFS hash of additional candidate information.
     */
    function getCandidateData(address _candidateAddress) external view returns (string memory, uint8, string memory, uint256, string memory) {
        Candidate memory candidate = candidates[_candidateAddress];
        return (candidate.name, candidate.age, candidate.image, candidate.voteCount, candidate.ipfs);
    }

    /**
     * @dev Returns the total number of registered candidates.
     * @return The total count of candidates.
     */
    function getCandidateCount() external view returns (uint256) {
        return candidateAddresses.length;
    }

    /**
     * @dev Registers a new voter for the election. Can only be called by the contract owner.
     * @param _add The Ethereum address of the voter.
     * @param _name The name of the voter.
     * @param _image The image URL of the voter.
     * @param _ipfs The IPFS hash of additional voter information.
     */
    function registerVoter(address _add, string memory _name, string memory _image, string memory _ipfs) external onlyOwner {
        increment(_voterId);
        uint256 idNumber = current(_voterId);

        Voter storage voter = voters[_add];
        require(voter.allowed == 0, "Already registered");

        voter.voterId = idNumber;
        voter.name = _name;
        voter.image = _image;
        voter.allowed = 1;
        voter.voted = false;
        voter.voterVote = 0;
        voter.ipfs = _ipfs;

        voterAddresses.push(_add);

        emit VoterCreated(idNumber, _name, _image, 1, false, 0, _ipfs);
    }

    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].allowed == 1, "You are not an authorized voter");
        _;
    }

    /**
     * @dev Allows a registered voter to cast a vote for a candidate.
     * @param _candidateAddress The Ethereum address of the candidate being voted for.
     * @param _candidateVoteId The candidate ID to validate the vote.
     */
    function vote(address _candidateAddress, uint256 _candidateVoteId) external onlyRegisteredVoter {
        Voter storage voter = voters[msg.sender];
        require(!voter.voted, "You have already voted");
        require(candidates[_candidateAddress]._address != address(0), "Candidate not found");
        require(candidates[_candidateAddress].candidateId == _candidateVoteId, "Invalid candidate ID");

        candidates[_candidateAddress].voteCount += 1;
        voter.voted = true;
        voter.voterVote = _candidateVoteId;

        votedVoters.push(msg.sender);
    }

    /**
     * @dev Returns the total number of registered voters.
     * @return The total count of voters.
     */
    function getVoterCount() external view returns (uint256) {
        return voterAddresses.length;
    }

    /**
     * @dev Returns the data of a specific voter by their address. Can only be called by a registered voter.
     * @param _voterAddress The Ethereum address of the voter.
     * @return voterId The unique ID of the voter.
     * @return name The name of the voter.
     * @return image The image URL of the voter.
     * @return allowed The allowed status of the voter (1 for allowed, 0 for not allowed).
     * @return voted A boolean indicating whether the voter has voted.
     * @return voterVote The ID of the candidate the voter voted for.
     * @return ipfs The IPFS hash of additional voter information.
     */
    function getVoterData(address _voterAddress) external view onlyRegisteredVoter returns (uint256, string memory, string memory, uint256, bool, uint256, string memory) {
        Voter memory voter = voters[_voterAddress];
        return (voter.voterId, voter.name, voter.image, voter.allowed, voter.voted, voter.voterVote, voter.ipfs);
    }

    /**
     * @dev Returns the addresses of voters who have already voted.
     * @return An array of addresses of voted voters.
     */
    function getVotedVoters() external view returns (address[] memory) {
        return votedVoters;
    }

    /**
     * @dev Returns the addresses of all registered voters.
     * @return An array of all registered voter addresses.
     */
    function getVoterList() external view returns (address[] memory) {
        return voterAddresses;
    }

    /**
     * @dev Retrieves the current vote count for a specific candidate.
     * @param _candidateAddress The Ethereum address of the candidate.
     * @return The current vote count of the candidate.
     */
    function getVoteCount(address _candidateAddress) external view returns (uint256) {
        return candidates[_candidateAddress].voteCount;
    }
}    
