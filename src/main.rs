pub mod giver;
pub mod contract;
pub mod voting_initiator;

use std::path::Path;
use ton_client_rs::TonClient;
use contract::SmartContract;
use giver::GiverContract;
use voting_initiator::VotingInitiatorContract;
use std::env::current_dir;

const CONTRACTS_FOLDER: &str = "contracts/";

fn main() {
    println!("Start");

    let ton_client = TonClient::new_with_base_url("http://0.0.0.0")
        .expect("Couldn't create ton client");

    let keys = ton_client.crypto.generate_ed25519_keys()
        .expect("Couldn't create key pair");

    let contracts_folder = current_dir().unwrap()
        .join(Path::new(CONTRACTS_FOLDER));

    let giver = GiverContract::new(&ton_client, &contracts_folder);

    let mut voting_initiator_contract = VotingInitiatorContract::new(
        &ton_client,
        &contracts_folder,
        &keys
    );

    let proposal_contract = SmartContract::new(
        &ton_client,
        &contracts_folder,
        "Proposal",
        Some(&keys),
        None
    );

    voting_initiator_contract.calculate_address();

    giver.send_grams(
        voting_initiator_contract.smart_contract.address.as_ref()
            .expect("Couldn't send grams from giver")
    );

    let code_path = contracts_folder.join("VotingWallet").with_extension("tvc");
    let code = std::fs::read(code_path).expect("Couldn't read wallet code");

    voting_initiator_contract.deploy(
        proposal_contract.code.as_ref()
            .expect("Couldn't deploy need proposal contract code"),
        &code
    );

    let wallet_code = voting_initiator_contract.get_wallet_contract();

    println!("Finish");
}

