pragma solidity >=0.5.0;

import "./ISMV.sol";

interface IProposal {
    function vote() public;

    function getStatus() public view returns (ProposalStatus);
}
