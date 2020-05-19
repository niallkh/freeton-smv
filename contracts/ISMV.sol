pragma solidity >=0.5.0;

interface ISMV {


    struct Proposal {
        address contract;
        uint256 id;
        string title;
        ProposalStatus status;
    }

    enum ProposalStatus {
        Waiting,
        InProgress,
        Finished,
    }

    function createProposal(
        uint256 proposalId,
        string proposalTitle,
        string link,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount
    ) public returns (Proposal);

    function registerVoter(address pubkey) public;

    function registerVoters(address[] pubkeys) public;

    function isVoter(address pubkey) public view returns (bool);

    function getProposal(uint256 proposalId) public view returns (Proposal);
}
