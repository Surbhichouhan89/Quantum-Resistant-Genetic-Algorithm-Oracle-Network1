// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract QuantumResistantGenAlgoOracleNetwork2 is Ownable {
    struct Candidate {
        bytes32 id;
        string solutionMetadata; // Off-chain storage reference (IPFS URI, etc.)
        uint256 fitnessScore;    // Lower is better or based on optimization
        uint256 generation;
        uint256 votes;
        bool valid;
    }

    struct OracleNode {
        bool isRegistered;
        uint256 reputation; // Reputation points for reliability
    }

    uint256 public currentGeneration;
    uint256 public candidateCount;
    uint256 public votingPeriodBlocks;
    uint256 public minReputationToVote;

    mapping(bytes32 => Candidate) public candidates;
    mapping(address => OracleNode) public oracleNodes;
    mapping(bytes32 => mapping(address => bool)) private votes; // candidate ID => voter => voted

    event CandidateSubmitted(bytes32 indexed candidateId, uint256 generation, string metadata);
    event Voted(bytes32 indexed candidateId, address indexed voter, uint256 votes);
    event GenerationAdvanced(uint256 newGeneration);
    event OracleRegistered(address indexed oracle);
    event OracleDeregistered(address indexed oracle);

    modifier onlyRegisteredOracle() {
        require(oracleNodes[msg.sender].isRegistered, "Not a registered oracle");
        _;
    }

    constructor(uint256 _votingPeriodBlocks, uint256 _minReputationToVote) {
        currentGeneration = 1;
        votingPeriodBlocks = _votingPeriodBlocks;
        minReputationToVote = _minReputationToVote;
    }

    /**
     * @dev Owner registers an oracle node
     */
    function registerOracle(address oracle) external onlyOwner {
        require(!oracleNodes[oracle].isRegistered, "Oracle already registered");
        oracleNodes[oracle] = OracleNode({isRegistered: true, reputation: 1});
        emit OracleRegistered(oracle);
    }

    /**
     * @dev Owner can deregister an oracle node
     */
    function deregisterOracle(address oracle) external onlyOwner {
        require(oracleNodes[oracle].isRegistered, "Oracle not registered");
        oracleNodes[oracle].isRegistered = false;
        emit OracleDeregistered(oracle);
    }

    /**
     * @dev Oracles submit candidate solution for current generation
     */
    function submitCandidate(bytes32 candidateId, string calldata solutionMetadata, uint256 fitnessScore) external onlyRegisteredOracle {
        require(!candidates[candidateId].valid, "Candidate ID already exists");

        candidates[candidateId] = Candidate({
            id: candidateId,
            solutionMetadata: solutionMetadata,
            fitnessScore: fitnessScore,
            generation: currentGeneration,
            votes: 0,
            valid: true
        });

        candidateCount++;
        emit CandidateSubmitted(candidateId, currentGeneration, solutionMetadata);
    }

    /**
     * @dev Oracles vote on a candidate for current generation solutions
     */
    function voteCandidate(bytes32 candidateId) external onlyRegisteredOracle {
        Candidate storage candidate = candidates[candidateId];
        require(candidate.valid, "Invalid candidate");
        require(candidate.generation == currentGeneration, "Candidate not in current generation");
        require(oracleNodes[msg.sender].reputation >= minReputationToVote, "Insufficient reputation to vote");
        require(!votes[candidateId][msg.sender], "Already voted for this candidate");

        votes[candidateId][msg.sender] = true;
        candidate.votes++;

        // Optionally increase reputation for fair voting etc.
        oracleNodes[msg.sender].reputation++;

        emit Voted(candidateId, msg.sender, candidate.votes);
    }

    /**
     * @dev Owner advances the generation, cleaning candidates and resetting state
     */
    function advanceGeneration() external onlyOwner {
        currentGeneration++;
        candidateCount = 0;

        // Reset candidates mapping not actually deleted in solidity but could be managed by off-chain indexing
        // Alternatively, new mappings or namespaces could be used per generation for off-chain processing

        emit GenerationAdvanced(currentGeneration);
    }

    /**
     * @dev Get candidate details
     */
    function getCandidate(bytes32 candidateId) external view returns (
        string memory solutionMetadata,
        uint256 fitnessScore,
        uint256 generation,
        uint256 votes,
        bool valid
    ) {
        Candidate storage c = candidates[candidateId];
        return (c.solutionMetadata, c.fitnessScore, c.generation, c.votes, c.valid);
    }

    /**
     * @dev Get oracle reputation
     */
    function getOracleReputation(address oracle) external view returns (uint256) {
        return oracleNodes[oracle].reputation;
    }
}
