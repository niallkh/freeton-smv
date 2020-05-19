pragma solidity >=0.5.0;

import "./ISMV.sol";

abstract contract IProposal {

    enum Status { WAITING, IN_PROGRESS, FINISHED }

    enum Vote { NO, YES }

    function vote(Vote vote) public virtual;

    function getStatus() public view virtual returns (Status);

    function getProposalTitle() public view virtual returns (string);

    function getLink() public view virtual returns (string);

    function getStartTime() public view virtual returns (uint256);

    function getFinishTime() public view virtual returns (uint256);

    function getVotersAmount() public view virtual returns (uint256);

    function getCountYesVotes() public view virtual returns (uint256);

    function getCountNoVotes() public view virtual returns (uint256);
}
