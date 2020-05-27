pragma solidity >=0.5.0;
pragma AbiHeader expire;

interface IVotingInitiator {

    function createProposal(
        uint256 proposalId,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount
    ) external returns (address);

    function getProposalContract() external view returns (TvmCell);
}

contract VotingInitiator is IVotingInitiator {

    mapping(uint256 => address) proposals;

    TvmCell proposalContract;

    modifier onlyOwner() {
        require(tvm.pubkey() == msg.pubkey(), 403);
        _;
    }

    constructor(TvmCell _proposalContract) public {
        require(tvm.pubkey() != 0, 400);
        tvm.accept();
        proposalContract = _proposalContract;
    }

    function createProposal(
        uint256 proposalId,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount
    ) external override onlyOwner returns (address) {
        require(!proposals.exists(proposalId), 400);
        tvm.accept();

        TvmCell proposalContractWithPubkey = tvm.insertPubkey(
            proposalContract,
            tvm.pubkey()
        );

        address proposalAddress = address(tvm.hash(proposalContractWithPubkey));

        uint32 constructorId = uint32(0x10000000);

        tvm.deployAndCallConstructor(
            proposalContractWithPubkey,
            proposalAddress,
            1_000_000_000,
            constructorId,
            tvm.pubkey(),
            proposalContract,
            proposalId,
            startTime,
            finishTime,
            votersAmount
        );

        proposals[proposalId] = proposalAddress;

        return proposalAddress;
    }

    function getProposalContract() external view override returns (TvmCell) {
        return proposalContract;
    }
}
