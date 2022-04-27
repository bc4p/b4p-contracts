import pytest
from brownie import config, network, Contract


@pytest.fixture(scope="module")
def marketRegistry(MarketRegistry, accounts ):
    return MarketRegistry.deploy({"from":accounts[0]})

@pytest.fixture
def energyToken(EnergyToken, accounts):
    return EnergyToken.deploy("url", {"from":accounts[1]})

@pytest.fixture
def eurs():
    eurs_address = config["networks"][network.show_active()].get("eurs")
    eurs = Contract.from_explorer(eurs_address)
    return eurs

@pytest.fixture
def market(marketRegistry, energyToken, Market, accounts, eurs):
    zero_address = "0x0000000000000000000000000000000000000000"
    return Market.deploy(eurs,energyToken,zero_address,zero_address,marketRegistry,1, {"from":accounts[2]})

@pytest.fixture
def twoMarkets(marketRegistry,energyToken,Market, accounts,eurs):
    zero_address = "0x0000000000000000000000000000000000000000"
    m1 = Market.deploy(eurs,energyToken,zero_address,zero_address,marketRegistry,1, {"from":accounts[0]})
    m2 = Market.deploy(eurs,energyToken,zero_address,zero_address,marketRegistry,1, {"from":accounts[1]})
    return m1, m2

@pytest.fixture
def producingAsset(ProducingAsset, marketRegistry, market, accounts):
    return ProducingAsset.deploy(market,marketRegistry, {"from":accounts[3]})






def test_market_registry(marketRegistry, market):
    print(marketRegistry.getMarkets())
    assert marketRegistry.getMarkets() == (market.address, )

def test_connection(twoMarkets):
    m1 = twoMarkets[0]
    m2 = twoMarkets[1]

def test_producing_asset(producingAsset):
    producingAsset.createOffer()


    

