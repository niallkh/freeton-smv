pragma solidity >=0.5.0;

import "./ISMV.sol";

contract SMV is ISMV {

    mapping(uint256 => uint8) votersPubkeys;

    mapping(uint256 => address) proposalsById;

    TvmCell proposalCode;

    uint256 ownerPubkey;

    modifier onlyOwner(uint256 pubkey) {
        require(msg.pubkey() == ownerPubkey, "Only owner");
        _;
    }

    constructor(uint256 ownerPubkey) {
        tvm.accept();
        this.ownerPubkey = ownerPubkey;
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
        require(!exists, "Proposal already exists");

        // TvmCell stateInit = tvm.buildStateInit(code, data);

        // // tvm.hash() - Runtime function that computes the representation hash ot TvmCell.
        // address addr = address(tvm.hash(stateInit));

        // // Functions to deploy a contract and call it's constructor.
        // tvm.deployAndCallConstructor(stateInit, addr, initial_balance, constructor_id, constructor_param0, constructor_param1);

        return address(0);
    }

    function getProposal(uint256 proposalId) public view override returns (address) {
        (bool exists, address proposalAddress) = proposalsById.fetch(proposalId);
        require(exists, "Proposal doesn't exist");

        return proposalAddress;
    }

    function setProposalCode(TvmCell code) public override {
        tvm.accept();
        proposalCode = code;
    }

    function registerVoter(uint256 pubkey) public override {
        require(!votersPubkeys[pubkey], "Voter already registered");
        tmv.accept();

        votersPubkeys[pubkey] = 1;
    }

    function registerVoters(uint256[] pubkeys) public override {
        uint256 arrayLength = pubkeys.length;

        for (uint i = 0; i < arrayLength; i++) {
            registerVoter(pubkeys[i]);
        }
    }

    function isVoter(uint256 pubkey) public view override returns (bool) {
        (bool exists, uint8 value) = votersPubkeys.fetch(proposalId);
        return exists;
    }
}
