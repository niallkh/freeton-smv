pragma solidity >=0.5.0;
pragma AbiHeader expire;

interface IVotingWallet {

    enum Vote {
        NO,
        YES
    }

    function vote(
        address proposalAddress,
        Vote _vote
    ) external;
}

contract VotingWallet is IVotingWallet {

    uint256 signature;

    constructor(uint256 _signature) public {
        require(tvm.pubkey() != 0, 400);
        signature = _signature;
    }

    function vote(
        address proposalAddress,
        Vote _vote
    ) external override {
        // TODO implement
    }

    onBounce(TvmSlice slice) external {
        // TODO implement
    }
}
