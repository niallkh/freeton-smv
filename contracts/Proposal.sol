pragma solidity >=0.5.0;

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
        uint256 proposalId,
        string proposalTitle,
        string link,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount,
        address smvContract
    ) {
        tvm.accept();
        this.id = proposalId;
        this.title = proposalTitle;
        this.link = link;
        this.startTime = startTime;
        this.finishTime = finishTime;
        this.votersAmount = votersAmount;
        this.smvContract = ISMV(smvContract);
    }

    function vote(Vote vote) public override {
        (bool exists, uint8 value) = votedPubkeys.fetch(msg.pubkey());
        require(!exists, "Voter already passed voice");
        tvm.accept();

        if (vote = Vote.YES) {
            countYes++;
        } else {
            countNo++;
        }
    }

    function getStatus() public view virtual returns (ProposalStatus) {
        return ProposalStatus.InProgress;
    }

    function getProposalTitle() public view virtual returns (string) {
        return title;
    }

    function getLink() public view virtual returns (string) {
        return link;
    }

    function getStartTime() public view virtual returns (uint256) {
        return startTime;
    }

    function getFinishTime() public view virtual returns (uint256) {
        return finishTime;
    }

    function getVotersAmount() public view virtual returns (uint256) {
        return votersAmount;
    }

    function getCountYesVotes() public view virtual returns (uint256) {
        return countYes;
    }

    function getCountNoVotes() public view virtual returns (uint256) {
        return countNo;
    }
}
