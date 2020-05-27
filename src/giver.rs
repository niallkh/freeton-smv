use crate::contract::SmartContract;
use std::path::Path;
use ton_client_rs::TonAddress;
use ton_client_rs::TonClient;
use serde_json::json;

const GIVER_ADDRESS: &str =
    "0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94";

pub struct GiverContract<'a> {
    pub smart_contract: SmartContract<'a>,
}

impl<'a> GiverContract<'a> {
    pub fn new(ton_client: &'a TonClient, folder: &Path) -> GiverContract<'a> {
        let smart_contract = SmartContract::new(
            ton_client,
            folder,
            "Giver",
            None,
            Some(TonAddress::from_str(GIVER_ADDRESS).expect("Can't parse giver address")),
        );

        GiverContract { smart_contract }
    }

    pub fn send_grams(&self, address: &TonAddress) {

        self.smart_contract.run(
            "sendGrams",
            Some(json!({
                "dest": address.to_string(),
                "amount": 1_000_000_000u64
            }).to_string().into()),
            None
        );
    }
}
