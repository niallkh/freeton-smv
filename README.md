# Summary
A standard interface for the Soft Majority Voting system.

# Abstract
The following proposal defines the standard interface designed to implement SMV system in TON blockchain within smart contracts. This proposal provides basic functionality to creating proposals and voting for them.

# Motivation 
We need a system of voting contracts to regulate governance and decision making in Free TON. This contract is a principal tool of decentralization. It is supposed to be used in many aspects of Free TON blockchain to provide mechanisms for community governance.

# Specification

## Glossary

Voting Initiator Contract (VIC) - a smart contract that can create new proposal and contains ids of all proposals
Proposal Contract (PC) - a smart contract for each proposal that manage voting process
Voter Wallet (VW) - a smart contract that can be used for voting by Voters
Proposal Creator Contract Public Key (VICPK) - public key of Proposal contract creator
Voter Waller Public Key (VWPC) - public key of Voter Wallet

## Requirements

* Should be at least two roles: "Initiator" and "Voter"
* Initiator should be able to create Proposal
* Voter should be able to vote for Proposal
* Proposal should have two options of voting: "YES" or "NO"
* Voter can vote only once on each proposal
* Protect Voting system from incorrect usage
* Proposal at the end of voting should notify about results
* Contract or any other contract in the system should not store voting participants ledger

## Description

**We have two roles for users:**
1. Initiator of voting system has two possibilities: **to grant the voting rights**, **create new proposal**. The right to vote is a signature of VW's address, so to give the voting right Initiator have to send signature on chain by directly to Voter's smart address. To create a new proposal, Initiator should submit a unique proposal id, uuid, start and finish times of voting and amount of voters.
2. Voter (using voting rights) can vote once for a specific Proposal. To obtain the voting right (signature), Voter should provide address of deployed VW.

**And we have three smart contracts:**
1. Voting Initiator Contract (VIC) has possibilities: create a new proposal by Initiator, obtain deployed Proposals and provide code for VW.
2. Voter Wallet (VW) has possibilities: **vote** by using address PC and voting rights. Voter can't deploy own implementation of smart contract and should use implementation provided by VIC. So to avoid double voting on one Proposal, need to remember address 
3. Proposal contract (PC) has possibilities: vote "YES" or "NO" for proposal, provide details about proposal: title, uuid and etc. PC should verify VW smart contract by using code of smart contract and VWPC. And PC should verify signature by using VICPK.

## Flow

1. Initiator deploy VIC with VICPK;
2. Voters deploy VW from code provided by VIC;
3. Initiator grant voting rights by sending signature of VW's address to VWs;
4. Initiator create new Proposal with parameters: proposal id, uuid, start time, finish time, voters amount;
5. Voter obtain address of PC from VIC by proposal id;
6. Voter send signature and vote to address of PS using VW;
7. When voting is finished PC should emit out message with results;

## Functions

### Interface VotingInitiator

Smart contract should store code of VW smart contract.

**createProposal**

External function. Create new proposal with parameters. Proposal id must unique. Return address of deployed PC.

```solidity
function createProposal(
    uint256 proposalId,
    bytes uuid,
    uint256 startTime,
    uint256 finishTime,
    uint256 votersAmount
) onlyInitiator returns (address)
```

**getVoterCode**

Return code for Voter contract.

```solidity
function getVoterCode() view returns (TvmCell)
```

**getProposalAddress**

Return address of PC by proposal id or throw error.

```solidity
function getProposalAddress() view returns (address)
```

### Interface VoterWallet

Smart contract should store address of VotingInitiator.

**vote**

External function. Vote for proposal. This method should ensure that Voter cannot vote more that once for proposal contract address. Choice should be " YES" or "NO".

```solidity
function vote(
    address proposalContractAddress,
    Choice choice
) onlyVoter
```

**saveSignature**

External function. Save signature which is voting right. Also we should protect this function from Initiator spam.

```solidity
function saveSignature(
    uint512 signature
) onlyInitiator
```

### Interface ProposalContract

Smart contract should store code of VW contract and VICPK.

**Choice**

```solidity
enum Choice { NO, YES }
```

**ProposalResult**

```solidity
event ProposalResult(
    uint256 yesChoices, 
    uint256 noChoices, 
    uint256 amountVoters
)
```

**vote**

Internal function. Vote for proposal "YES" or "NO". 
Function should verify that msg sender is address of valid VC. Should use stored code of VW code and sender's public key. (example: [ Verification check](https://forum.freeton.org/t/tip-3-distributed-token-or-ton-cash/64) )
Next Function should verify signature. Need to hash senders address with proposal id and check signature with VICPK. ([tvm.checkSign()](https://github.com/tonlabs/TON-Solidity-Compiler/blob/master/API.md#tvmchecksign))
Function should verify current time and active time of proposal by start and finish time.
Function should count "YES" and "NO" choices.

```solidity
function vote(
    uint512 signature,
    Choice choice
) 
```

**finish**

External function. Check finish time of proposal. If time is expired so emit event result. Should invoke only once.

```solidity
function finish() 
```

**getProposalId**

```solidity
function getProposalId() view returns (uint256) 
```

**getUuid**

```solidity
function getUuid() view returns (bytes)
```

**getAmountVoters**

```solidity
function getAmountVoters() view returns (uint256) 
```

**getStartTime**

```solidity
function getStartTime() view returns (uint256) 
```

**getFinishTime**

```solidity
function getFinishTime() view returns (uint256) 
```

## Rationale

Advantages:
* Shouldn't store ledger of voters due to use of signature.
* Shouldn't store ledger of voters to avoid voting more than once for one proposal.
* Can add rule for distribution of Voting rights by sending not only signature but message with rule signed initiator.
* Has possibility to upgrade code of PC and VIC.

Limitations:
* Can't reject the Voting rights
* Can't upgrade Voter Contract
