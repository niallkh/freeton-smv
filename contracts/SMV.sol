pragma solidity >=0.5.0;
pragma AbiHeader expire;

import "./ISMV.sol";

contract SMV is ISMV {

    mapping(uint256 => uint8) votersPubkeys;

    mapping(uint256 => address) proposalsById;

    TvmCell proposalCode;

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
        string proposalTitle,
        string link,
        uint256 startTime,
        uint256 finishTime,
        uint256 votersAmount
    ) public override returns (address) {
        (bool exists, address proposalAddress) = proposalsById.fetch(proposalId);
        require(!exists, 400);

        // TvmCell stateInit = tvm.buildStateInit(code, data);

        // // tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
        // address addr = address(tvm.hash(stateInit));

        // // Functions to deploy a contract and call it's constructor.
        // tvm.deployAndCallConstructor(stateInit, addr, initial_balance, constructor_id, constructor_param0, constructor_param1);

        return address(0);
    }

    function getProposal(uint256 proposalId) public view override returns (address) {
        (bool exists, address proposalAddress) = proposalsById.fetch(proposalId);
        require(exists, 404);

        return proposalAddress;
    }

    function setProposalCode(TvmCell code) public override {
        tvm.accept();
        proposalCode = code;
    }

    function registerVoter(uint256 pubkey) public override {
        (bool exists, uint8 value) = votersPubkeys.fetch(pubkey);
        require(!exists, 400);
        tvm.accept();

        votersPubkeys[pubkey] = 1;
    }

    function registerVoters(uint256[] pubkeys) public override {
        uint256 arrayLength = pubkeys.length;

        for (uint i = 0; i < arrayLength; i++) {
            registerVoter(pubkeys[i]);
        }
    }

    function isVoter(uint256 pubkey) public view override returns (bool) {
        (bool exists, uint8 value) = votersPubkeys.fetch(pubkey);
        return exists;
    }

    function isInitiator(uint256 pubkey) public view returns (bool) {
        return initiator == pubkey;
    }
}
