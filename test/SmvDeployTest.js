const expect = require('chai').expect
const getGramsFromGiver = require('./giver.js');
const SMVContract = require('../contracts/SMVContract.js')
const { TONClient } = require('ton-client-node-js');

describe('SMV contract', function () {
    this.timeout(5000);

    let tonClient

    before(async () => {
        tonClient = await TONClient.create({
            servers: ['http://0.0.0.0']
        });

        keys = await tonClient.crypto.ed25519Keypair();
    })

    let keys
    let address

    it('Send grams to future address from giver', async () => {
        const expectedGrams = 1000000000;

        const futureAddress = (await tonClient.contracts.createDeployMessage({
            package: SMVContract.package,
            constructorParams: {},
            keyPair: keys,
        })).address;

        await getGramsFromGiver(tonClient, futureAddress, expectedGrams);

        address = futureAddress

        const balance = await getBalance(tonClient, address);

        expect(expectedGrams).to.be.equal(balance);
    });

    let contract

    it('Deploy SMV contract', async () => {
        contract = new SMVContract(tonClient, address, keys);

        await contract.deploy();

        const isInitiator = (await contract.isInitiatorLocal({
            pubkey: `0x${keys.public}`
        })).value0;

        expect(isInitiator).to.be.equal(true);
    })
});

async function getBalance(client, address) {
    const result = await client.queries.accounts.query({
        id: { eq: address }
    }, 'balance');
    return parseInt(result[0].balance, 16);
}
