Off-chain storage reference (IPFS URI, etc.)
        uint256 fitnessScore;    Reputation points for reliability
    }

    uint256 public currentGeneration;
    uint256 public candidateCount;
    uint256 public votingPeriodBlocks;
    uint256 public minReputationToVote;

    mapping(bytes32 => Candidate) public candidates;
    mapping(address => OracleNode) public oracleNodes;
    mapping(bytes32 => mapping(address => bool)) private votes; Optionally increase reputation for fair voting etc.
        oracleNodes[msg.sender].reputation++;

        emit Voted(candidateId, msg.sender, candidate.votes);
    }

    /**
     * @dev Owner advances the generation, cleaning candidates and resetting state
     */
    function advanceGeneration() external onlyOwner {
        currentGeneration++;
        candidateCount = 0;

        Alternatively, new mappings or namespaces could be used per generation for off-chain processing

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
// 
End
// 
