use crate::contract::SmartContract;
use serde_json::json;
use std::path::Path;
use ton_client_rs::Ed25519KeyPair;
use ton_client_rs::TonClient;

pub struct VotingInitiatorContract<'a> {
    pub smart_contract: SmartContract<'a>,
}

impl<'a> VotingInitiatorContract<'a> {
    pub fn new(
        ton_client: &'a TonClient,
        contracts_folder: &Path,
        keys: &'a Ed25519KeyPair,
    ) -> VotingInitiatorContract<'a> {
        VotingInitiatorContract {
            smart_contract: SmartContract::new(
                &ton_client,
                &contracts_folder,
                "VotingInitiator",
                Some(&keys),
                None,
            ),
        }
    }

    pub fn deploy(&mut self, proposal_contract: &[u8]) {
        self.smart_contract.deploy(Some(
            json!({ "_proposalContract": hex_encode(proposal_contract) })
                .to_string()
                .into(),
        ));
    }

    pub fn calculate_address(&mut self) {
        self.smart_contract.calculate_address();
    }
}

fn hex_encode(data: &[u8]) -> String {
    let hex_table = [
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
    ];

    let mut string = String::with_capacity(data.len());

    string.push_str("0x");

    for byte in data.iter() {
        let left = byte >> 4;
        let right = (byte << 4) >> 4;

        string.push(hex_table[left as usize]);
        string.push(hex_table[right as usize]);
    }

    string
}
