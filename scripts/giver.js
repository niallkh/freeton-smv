const { TONClient } = require('ton-client-node-js');

//address of giver on NodeSE
const giverAddress = '0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94';

//giver ABI on NodeSE
const giverAbi = {
    'ABI version': 1,
    'functions': [
    {
        'name': 'constructor',
        'inputs': [],
        'outputs': []
    },
    {
        'name': 'sendGrams',
        'inputs': [
        {'name': 'dest', 'type': 'address'},
        {'name': 'amount', 'type': 'uint64'}
        ],
        'outputs': []
    }
    ],
    'events': [],
    'data': []
};

async function getGramsFromGiver(client, account, amount) {
    const { contracts, queries } = client;
    await contracts.run({
        address: giverAddress,
        functionName: 'sendGrams',
        abi: giverAbi,
        input: {
            dest: account,
            amount: amount
        },
        keyPair: null,
    });

    await queries.accounts.waitFor(
        {
            id: { eq: account },
            balance: { gt: "0" }
        },
        'id balance'
    );
}

module.exports = getGramsFromGiver;
