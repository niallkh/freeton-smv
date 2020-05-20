pragma solidity >=0.5.0;
pragma AbiHeader expire;

import "./ISMV.sol";

contract SMV is ISMV {

    mapping(uint256 => uint8) votersPubkeys;

    mapping(uint256 => address) proposalsById;

    TvmCell proposalContract;

    uint256 initiator;

    modifier onlyInitiator(uint256 pubkey) {
        require(msg.pubkey() == initiator, 403);
        _;
    }

    constructor() public {
        tvm.accept();
        initiator = tvm.pubkey();
    }

    function createProposal(
        uint256 proposalId,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount,
        uint128 amountGrams,
        uint256 pubkey
    ) external override returns (address) {
        (bool exists, address _) = proposalsById.fetch(proposalId);
        require(!exists, 400);
        tvm.accept();

        TvmCell proposalContractWithPubkey = tvm.insertPubkey(
            proposalContract,
            pubkey
        );

        address proposalAddress = address(tvm.hash(proposalContractWithPubkey));

        uint32 constructorId = uint32(0x10000000);

        tvm.deployAndCallConstructor(
            proposalContractWithPubkey,
            proposalAddress,
            amountGrams,
            constructorId,
            proposalId,
            startTime,
            finishTime,
            votersAmount,
            address(this)
        );

        proposalsById[proposalId] = proposalAddress;

        return proposalAddress;
    }


    function setProposalContract(TvmCell contr) external override {
        tvm.accept();
        proposalContract = contr;
    }

    function registerVoter(uint256 pubkey) external override {
        (bool exists, uint8 value) = votersPubkeys.fetch(pubkey);
        require(!exists, 400);
        tvm.accept();

        votersPubkeys[pubkey] = 1;
    }

    function getProposal(uint256 proposalId) external view override returns (address) {
        (bool exists, address proposalAddress) = proposalsById.fetch(proposalId);
        require(exists, 404);

        return proposalAddress;
    }

    function isVoter(uint256 pubkey) external view override returns (bool) {
        (bool exists, uint8 value) = votersPubkeys.fetch(pubkey);
        return exists;
    }

    function isInitiator(uint256 pubkey) external view returns (bool) {
        return initiator == pubkey;
    }
}
