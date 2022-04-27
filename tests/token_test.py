import pytest


@pytest.fixture
def energyToken(EnergyToken, accounts):
    return EnergyToken.deploy("url", {"from":accounts[1]})

def test_url(energyToken):
    energyToken.uri(0) == "url"
    energyToken.uri(1000000000000000) == "url"

    

