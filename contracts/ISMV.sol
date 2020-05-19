pragma solidity >=0.5.0;

abstract contract ISMV {

    function createProposal(
        uint256 proposalId,
        string proposalTitle,
        string link,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount
    ) public virtual returns (address);

    function registerVoter(uint256 pubkey) public virtual;

    function registerVoters(uint256[] pubkeys) public virtual;

    function isVoter(uint256 pubkey) public view virtual returns (bool);

    function getProposal(uint256 proposalId) public view virtual returns (address);

    function setProposalCode(TvmCell code) public virtual;
}
