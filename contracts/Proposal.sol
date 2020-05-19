pragma solidity >=0.5.0;
pragma AbiHeader expire;

import "./IProposal.sol";
import "./ISMV.sol";

contract Proposal is IProposal {

    uint256 id;
    string title;
    string link;
    uint256 startTime;
    uint256 finishTime;
    uint256 votersAmount;

    ISMV smvContract;

    uint256 countYes;
    uint256 countNo;

    mapping(uint256 => uint8) votedPubkeys;

    constructor(
        uint256 _proposalId,
        string _proposalTitle,
        string _link,
        uint256 _startTime,
        uint256 _finishTime,
        uint256 _votersAmount,
        address _smvContract
    ) public {
        tvm.accept();
        id = _proposalId;
        title = _proposalTitle;
        link = _link;
        startTime = _startTime;
        finishTime = _finishTime;
        votersAmount = _votersAmount;
        smvContract = ISMV(_smvContract);
    }

    function vote(Vote _vote) public override {
        (bool exists, uint8 value) = votedPubkeys.fetch(msg.pubkey());
        require(!exists, 400);
        tvm.accept();
        require(smvContract.isVoter(msg.pubkey()), 400);

        if (_vote == Vote.YES) {
            countYes++;
        } else {
            countNo++;
        }

        votedPubkeys[msg.pubkey()] = 1;
    }

    function getStatus() public view override returns (Status) {
        return Status.IN_PROGRESS;
    }

    function getProposalTitle() public view override returns (string) {
        return title;
    }

    function getLink() public view override returns (string) {
        return link;
    }

    function getStartTime() public view override returns (uint256) {
        return startTime;
    }

    function getFinishTime() public view override returns (uint256) {
        return finishTime;
    }

    function getVotersAmount() public view override returns (uint256) {
        return votersAmount;
    }

    function getCountYesVotes() public view override returns (uint256) {
        return countYes;
    }

    function getCountNoVotes() public view override returns (uint256) {
        return countNo;
    }
}
