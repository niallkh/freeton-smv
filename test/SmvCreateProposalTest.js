const expect = require('chai').expect
const getGramsFromGiver = require('./giver.js');
const SMVContract = require('../contracts/SMVContract.js')
const ProposalContract = require('../contracts/ProposalContract.js')
const { TONClient } = require('ton-client-node-js');

describe("SMV Create Proposal", function () {
    this.timeout(5000);

    let smvContract;
    let tonClient;
    let keys;

    before(async () => {
        tonClient = await TONClient.create({
            servers: ['http://0.0.0.0']
        });

        keys = await tonClient.crypto.ed25519Keypair();

        smvContract = await deploySmv(tonClient, keys);
    })

    it("Set Proposal code", async () => {
        await smvContract.setProposalContract({
            contr: ProposalContract.package.imageBase64
        })
    })

    it("Create Proposal", async () => {
        const expectedGrams = 100000000
        const expectedProposalId = 1
        const expectedStartTime = 3
        const expectedFinishTime = 4
        const expectedVotersAmount = 5

        const proposalKeys = await tonClient.crypto.ed25519Keypair();

        const constuctorId = await tonClient.contracts.getFunctionId({
            abi: ProposalContract.package.abi,
            function: 'constructor',
            input: true,
        });

        const proposalAddress = (await smvContract.createProposal({
            proposalId: expectedProposalId,
            startTime: expectedStartTime,
            finishTime: expectedFinishTime,
            votersAmount: expectedVotersAmount,
            amountGrams: expectedGrams,
            pubkey: `0x${proposalKeys.public}`
        })).value0

        await tonClient.queries.accounts.waitFor({
            id: { eq: proposalAddress },
            balance: { gt: "0" }
        }, 'id balance');

        const proposalContract = new ProposalContract(tonClient, proposalAddress, proposalKeys)

        const status = (await proposalContract.getStatusLocal()).value0
        const startTime = (await proposalContract.getStartTimeLocal()).value0
        const finishTime = (await proposalContract.getFinishTimeLocal()).value0
        const votersAmount = (await proposalContract.getVotersAmountLocal()).value0
        const countYes = (await proposalContract.getCountYesVotesLocal()).value0
        const countNo = (await proposalContract.getCountNoVotesLocal()).value0

        expect(parseInt(status, 16)).to.be.equal(1)
        expect(parseInt(startTime, 16)).to.be.equal(expectedStartTime)
        expect(parseInt(finishTime, 16)).to.be.equal(expectedFinishTime)
        expect(parseInt(votersAmount, 16)).to.be.equal(expectedVotersAmount)
        expect(parseInt(countYes, 16)).to.be.equal(0)
        expect(parseInt(countNo, 16)).to.be.equal(0)
    })
})

async function deploySmv(tonClient, keys) {

    const futureAddress = (await tonClient.contracts.createDeployMessage({
        package: SMVContract.package,
        constructorParams: {},
        keyPair: keys,
    })).address;

    await getGramsFromGiver(tonClient, futureAddress, 1000000000);

    const contract = new SMVContract(tonClient, futureAddress, keys);

    await contract.deploy();

    return contract;
}

async function getBalance(client, address) {
    const result = await client.queries.accounts.query({
        id: { eq: address }
    }, 'balance');
    return parseInt(result[0].balance, 16);
}

async function delay(time) {
    return Promise.resolve((res, rej) => {
        setTimeout(() => res(), time)
    })
}
