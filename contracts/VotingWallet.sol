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

contract VotingWallet {

    uint512 signature;

    constructor(uint512 _signature) {
        require(tmv.pubkey() != 0, 400);
        signature = _signature;
    }

    function vote(
        address proposalAddress,
        Vote _vote
    ) external override {
        // TODO implement
    }

    function onBounce(TvmSlice slice) external override {
        // TODO implement
    }
}
