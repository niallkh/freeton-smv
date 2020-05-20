pragma solidity >=0.5.0;
pragma AbiHeader expire;

import "./IProposal.sol";

interface ISMV {
    function isVoter(uint256 pubkey) external view returns (bool);
}

contract Proposal is IProposal {

    uint256 id;
    uint256 startTime;
    uint256 finishTime;
    uint256 votersAmount;

    ISMV smvContract;

    uint256 countYes;
    uint256 countNo;

    mapping(uint256 => uint8) votedPubkeys;

    constructor(
        uint256 _proposalId,
        uint256 _startTime,
        uint256 _finishTime,
        uint256 _votersAmount,
        address _smvContract
    ) public functionID(0x10000000) {
        tvm.accept();
        id = _proposalId;
        startTime = _startTime;
        finishTime = _finishTime;
        votersAmount = _votersAmount;
        smvContract = ISMV(_smvContract);
    }

    function vote(Vote _vote) external override {
        (bool exists, uint8 value) = votedPubkeys.fetch(msg.pubkey());
        require(!exists, 400);
        tvm.accept();

        if (_vote == Vote.YES) {
            countYes++;
        } else if (_vote == Vote.NO) {
            countNo++;
        } else {
        }

        votedPubkeys[msg.pubkey()] = 1;
    }

    function getStatus() external view override returns (Status) {
        return Status.IN_PROGRESS;
    }

    function getProposalId() external view override returns (uint256) {
        return id;
    }

    function getStartTime() external view override returns (uint256) {
        return startTime;
    }

    function getFinishTime() external view override returns (uint256) {
        return finishTime;
    }

    function getVotersAmount() external view override returns (uint256) {
        return votersAmount;
    }

    function getCountYesVotes() external view override returns (uint256) {
        return countYes;
    }

    function getCountNoVotes() external view override returns (uint256) {
        return countNo;
    }
}
