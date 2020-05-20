pragma solidity >=0.5.0;

interface ISMV {

    function createProposal(
        uint256 proposalId,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount,
        uint128 amountGrams,
        uint256 pubkey
    ) external returns (address);

    function registerVoter(uint256 pubkey) external;

    function isVoter(uint256 pubkey) external view returns (bool);

    function getProposal(uint256 proposalId) external view returns (address);

    function setProposalContract(TvmCell contr) external;
}
