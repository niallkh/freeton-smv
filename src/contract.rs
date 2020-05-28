use serde_json::Value;
use std::path::Path;
use ton_client_rs::Ed25519KeyPair;
use ton_client_rs::RunParameters;
use ton_client_rs::TonAddress;
use ton_client_rs::TonClient;

pub struct SmartContract<'a> {
    pub ton_client: &'a TonClient,
    pub abi: String,
    pub address: Option<TonAddress>,
    pub keys: Option<&'a Ed25519KeyPair>,
    pub code: Option<Vec<u8>>,
}

impl<'a> SmartContract<'a> {
    pub fn new(
        ton_client: &'a TonClient,
        folder: &Path,
        name: &str,
        keys: Option<&'a Ed25519KeyPair>,
        address: Option<TonAddress>,
    ) -> SmartContract<'a> {
        let abi = std::fs::read_to_string(folder.join(name).with_extension("abi.json"))
            .expect("Couldn't read abi");

        let code_path = folder.join(name).with_extension("tvc");
        let code = if code_path.exists() {
            let code = std::fs::read(code_path).expect("Couldn't read code");
            Some(code)
        } else {
            None
        };

        SmartContract {
            ton_client,
            abi,
            keys,
            address,
            code,
        }
    }

    pub fn deploy(
        &mut self,
        params: Option<RunParameters>,
    ) {
        let result = self
            .ton_client
            .contracts
            .deploy(
                &self.abi,
                self.code.as_ref().expect("To deploy contract need code"),
                None,
                params.unwrap_or_else(|| "{}".into()),
                None,
                self.keys.as_ref().expect("To deploy contract need keys"),
                0,
            )
            .expect("Couldn't deploy contract");

        self.address = Some(result.address);
    }

    pub fn calculate_address(&mut self) {
        let address = self
            .ton_client
            .contracts
            .get_deploy_address(
                &self.abi,
                self.code.as_ref().expect("To deploy contract need code"),
                None,
                &self
                    .keys
                    .as_ref()
                    .expect("To calculate address need keys")
                    .public,
                0,
            )
            .expect("Couldn't create deploy message");

        self.address = Some(address);
    }

    pub fn run(
        &self,
        fn_name: &str,
        params: Option<RunParameters>,
        header: Option<RunParameters>,
    ) -> Value {
        let ton_result = self.ton_client.contracts.run(
            self.address.as_ref()
                .expect("Couldn't send grams, provide giver address"),
            &self.abi,
            fn_name,
            header,
            params.unwrap_or_else(|| "{}".into()),
            self.keys
        ).expect("Couldn't run contract");

        println!("{}: {}", fn_name, ton_result.to_string());

        ton_result
    }

    pub fn run_local(
        &self,
        fn_name: &str,
        params: Option<RunParameters>,
        header: Option<RunParameters>,
    ) -> Value {
        let ton_result = self.ton_client
            .contracts
            .run_local(
                self.address
                    .as_ref()
                    .expect("Couldn't send grams, provide giver address"),
                None,
                &self.abi,
                fn_name,
                header,
                params.unwrap_or_else(|| "{}".into()),
                self.keys,
            )
            .expect("Couldn't run contract");

        println!("{}: {}", fn_name, ton_result.to_string());

        ton_result
    }
}
