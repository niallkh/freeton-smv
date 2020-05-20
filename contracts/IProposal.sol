pragma solidity >=0.5.0;

interface IProposal {

    enum Status { WAITING, IN_PROGRESS, FINISHED }

    enum Vote { NO, YES }

    function vote(Vote _vote) external;

    function getStatus() external view returns (Status);

    function getProposalId() external view returns (uint256);

    function getStartTime() external view returns (uint256);

    function getFinishTime() external view returns (uint256);

    function getVotersAmount() external view returns (uint256);

    function getCountYesVotes() external view returns (uint256);

    function getCountNoVotes() external view returns (uint256);
}
