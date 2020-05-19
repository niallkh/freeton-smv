const expect = require('chai').expect
const getGramsFromGiver = require('../scripts/giver.js');
const SMVContract = require('../contracts/SMVContract.js')
const { TONClient } = require('ton-client-node-js');

describe('SMV contract', () => {

    let tonClient

    it("Create ton client", async () => {
        tonClient = await TONClient.create({
            servers: ['http://0.0.0.0']
        });
    })

    let keys
    let address

    it('Send grams to future address', async () => {
        const expectedGrams = 1000000000;
        keys = await tonClient.crypto.ed25519Keypair();

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

        console.log(`0x${keys.public}`)

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
