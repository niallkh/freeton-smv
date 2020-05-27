pragma solidity >=0.5.0;
pragma AbiHeader expire;

interface IProposal {

    enum Vote {
        NO,
        YES
    }

    event ProposalResult();

    function vote(
        Vote _vote,
        uint256 signature
    ) external;

    function finish() external;
}

contract Proposal is IProposal {

    uint256 initiatorPubkey;
    TvmCell voterWalletCode;

    uint256 proposalId;
    uint256 startTime;
    uint256 finishTime;
    uint256 votersAmount;

    bool finished;

    uint256 yesVotes;
    uint256 noVotes;

    constructor(
        uint256 _initiatorPubkey,
        TvmCell _voterWalletCode,
        uint256 _proposalId,
        uint256 _startTime,
        uint256 _finishTime,
        uint256 _votersAmount
    ) public functionID(0x10000000) {
        initiatorPubkey = _initiatorPubkey;
        voterWalletCode = _voterWalletCode;
        proposalId = _proposalId;
        startTime = _startTime;
        finishTime = _finishTime;
        votersAmount = _votersAmount;
        finished = false;
        yesVotes = 0;
        noVotes = 0;
    }

    function vote(
        Vote _vote,
        uint256 signature
    ) external override {
        require(msg.sender.value != 0, 403);
        require(now >= startTime && now <= finishTime, 400);

        // TODO check signature
        // bool checked = tvm.checkSign(
        //     tvm.hash(msg.sender.value),
        //     uint256(signature),
        //     uint256(signature >> 256),
        //     initiatorPubkey
        // );
        // require(checked, 400);

        // TODO check code contract

        if (_vote == Vote.YES) {
            yesVotes++;
        } else if (_vote == Vote.NO) {
            noVotes++;
        } else {
            // throw error
        }
    }

    function finish() external override {
        require(now > finishTime, 400);
        require(!finished, 400);

        emit ProposalResult();
        finished = true;
    }

    function getProposalId() external view returns (uint256) {
        return proposalId;
    }
}
