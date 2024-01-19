// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VotingContract {
    address private _owner;
    bool private _electionStarted;

    /**
     * @dev Custom error definitions for specific failure scenarios.
     */
    error NotOwner();
    error ElectionNotStarted();
    error ElectionAlreadyStarted();
    error UnauthorizedVoter();
    error VoterAlreadyRegistered();
    error VoterNotFound();
    error CandidateNotFound();
    error InvalidCandidateId();
    error AlreadyVoted();

    /**
     * @dev Constructor to initialize the contract with the deployer as the owner.
     */
    constructor() {
        _owner = msg.sender; // Setting the contract deployer as the owner
        _electionStarted = false; // Initial state of the election
    }

    /**
     * @dev Modifier to restrict access to the contract's owner.
     */
    modifier onlyOwner() {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }

    /**
     * @dev Modifier to check if the election has started and if the caller is an authorized voter.
     */
    modifier onlyAuthorized() {
        if (!_electionStarted) revert ElectionNotStarted();
        if (voters[msg.sender].allowed != 1) revert UnauthorizedVoter();
        _;
    }

    /**
     * @dev Structure to manage incremental IDs.
     */
    struct Counter {
        uint256 _value;
    }

    Counter private _voterId;
    Counter private _candidateId;

    /**
     * @dev Function to increment the counter value.
     * @param counter The counter to increment.
     */
    function increment(Counter storage counter) private {
        counter._value += 1;
    }

    /**
     * @dev Function to get the current value of the counter.
     * @param counter The counter to retrieve the value from.
     * @return The current value of the counter.
     */
    function current(Counter storage counter) private view returns (uint256) {
        return counter._value;
    }

    /**
     * @dev Structure to store candidate information.
     */
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

    /**
     * @dev Structure to store voter information.
     */
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
     * @dev Function to register a new candidate. Can only be called by the owner.
     * @param _add The address of the candidate.
     * @param _name The name of the candidate.
     * @param _age The age of the candidate.
     * @param _image The image URL of the candidate.
     * @param _ipfs The IPFS hash of additional candidate information.
     */
    function setCandidate(address _add, string memory _name, uint8 _age, string memory _image, string memory _ipfs) external onlyOwner {
        if (!_electionStarted) revert ElectionNotStarted();
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
     * @dev Function to get the addresses of all registered candidates.
     * @return An array of candidate addresses.
     */
    function getCandidateAddresses() external view returns (address[] memory) {
        return candidateAddresses;
    }

    /**
     * @dev Function to get data of a specific candidate by their address.
     * @param _candidateAddress The address of the candidate.
     * @return The name, age, image URL, vote count, and IPFS hash of the candidate.
     */
    function getCandidateData(address _candidateAddress) external view returns (string memory, uint8, string memory, uint256, string memory) {
        if (candidates[_candidateAddress]._address == address(0)) revert CandidateNotFound();
        Candidate memory candidate = candidates[_candidateAddress];
        return (candidate.name, candidate.age, candidate.image, candidate.voteCount, candidate.ipfs);
    }

    /**
     * @dev Function to get the total number of registered candidates.
     * @return The total count of candidates.
     */
    function getCandidateCount() external view returns (uint256) {
        return candidateAddresses.length;
    }

    /**
     * @dev Function to register a new voter. Can only be called by the owner.
     * @param _add The address of the voter.
     * @param _name The name of the voter.
     * @param _image The image URL of the voter.
     * @param _ipfs The IPFS hash of additional voter information.
     */
    function registerVoter(address _add, string memory _name, string memory _image, string memory _ipfs) external onlyOwner {
        if (!_electionStarted) revert ElectionNotStarted();
        increment(_voterId);
        uint256 idNumber = current(_voterId);

        Voter storage voter = voters[_add];
        if (voter.allowed != 0) revert VoterAlreadyRegistered();

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

    /**
     * @dev Modifier to restrict access to registered voters.
     */
    modifier onlyRegisteredVoter() {
        if (voters[msg.sender].allowed != 1) revert UnauthorizedVoter();
        _;
    }

    /**
     * @dev Function to allow a registered voter to cast a vote.
     * @param _candidateAddress The address of the candidate being voted for.
     * @param _candidateVoteId The ID of the candidate to validate the vote.
     */
    function vote(address _candidateAddress, uint256 _candidateVoteId) external onlyAuthorized {
        Voter storage voter = voters[msg.sender];
        if (voter.voted) revert AlreadyVoted();
        if (candidates[_candidateAddress]._address == address(0)) revert CandidateNotFound();
        if (candidates[_candidateAddress].candidateId != _candidateVoteId) revert InvalidCandidateId();

        candidates[_candidateAddress].voteCount += 1;
        voter.voted = true;
        voter.voterVote = _candidateVoteId;

        votedVoters.push(msg.sender);
    }

    /**
     * @dev Function to get the total number of registered voters.
     * @return The total count of voters.
     */
    function getVoterCount() external view returns (uint256) {
        return voterAddresses.length;
    }

    /**
     * @dev Function to get data of a specific voter by their address.
     * @param _voterAddress The address of the voter.
     * @return The voter ID, name, image URL, allowed status, voting status, voter's vote, and IPFS hash of the voter.
     */
    function getVoterData(address _voterAddress) external view onlyRegisteredVoter returns (uint256, string memory, string memory, uint256, bool, uint256, string memory) {
        if (voters[_voterAddress].allowed == 0) revert VoterNotFound();
        Voter memory voter = voters[_voterAddress];
        return (voter.voterId, voter.name, voter.image, voter.allowed, voter.voted, voter.voterVote, voter.ipfs);
    }

    /**
     * @dev Function to get the addresses of voters who have already voted.
     * @return An array of addresses of voters who have voted.
     */
    function getVotedVoters() external view returns (address[] memory) {
        return votedVoters;
    }

    /**
     * @dev Function to get the list of all registered voter addresses.
     * @return An array of registered voter addresses.
     */
    function getVoterList() external view returns (address[] memory) {
        return voterAddresses;
    }

    /**
     * @dev Function to retrieve the current vote count for a specific candidate.
     * @param _candidateAddress The address of the candidate.
     * @return The current vote count of the candidate.
     */
    function getVoteCount(address _candidateAddress) external view returns (uint256) {
        return candidates[_candidateAddress].voteCount;
    }

    /**
     * @dev Function to start the election. Can only be called by the owner.
     */
    function startElection() external onlyOwner {
        if (_electionStarted) revert ElectionAlreadyStarted();
        _electionStarted = true;
    }

     /**
     * @dev Function to end the election. Can only be called by the owner.
     */
    function endElection() external onlyOwner {
        if (!_electionStarted) revert ElectionNotStarted();
        _electionStarted = false;
    }
}