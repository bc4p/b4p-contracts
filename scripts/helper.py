from brownie import (
    accounts,
    network,
    config,
    MockV3Aggregator,
    Contract,
    interface,
    chain
)

FORKED_LOCAL_ENVIRONMENTS = ["bc4p-mainnet", "eth-mainnet-fork", ]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]


def get_account(index=None, id=None):
    print(index)
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    return accounts.add(config["wallets"]["faucet"])

def generate_accounts(num_accounts):
    new_accounts = []
    print(f"generating {num_accounts} new accounts...\n")
    for i in range(num_accounts):
        new_accounts.append(accounts.add())
    if (network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    or network.show_active() in FORKED_LOCAL_ENVIRONMENTS):
        faucet = accounts[0]
    else:
        faucet = accounts.add(config["wallets"]["faucet"])
    fundAccounts(new_accounts, faucet)
    return new_accounts

def get_latest_accounts(latest):

    return accounts[(len(accounts)-latest):]

def fundAccounts(generated_accounts, faucet, funding_amount="0.3 ether"):
    for account in generated_accounts:
        tx = faucet.transfer(account, funding_amount, gas_price="30 gwei")
        tx.wait(1)




contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
}

def get_contract(contract_name):
    """This function will grab the contract addresses from the brownie config
    if defined, otherwise, it will deploy a mock version of that contract, and
    return that mock contract.

        Args:
            contract_name (string)

        Returns:
            brownie.network.contract.ProjectContract: The most recently deployed
            version of this contract.
    """
    contract_type = contract_to_mock[contract_name]
    print(network.show_active())
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
    return contract


DECIMALS = 8
INITIAL_VALUE = 200000000000


def deploy_mocks(decimals=DECIMALS, initial_value=INITIAL_VALUE):
    account = get_account()
    MockV3Aggregator.deploy(decimals, initial_value, {"from": account})
    print("Deployed!")


