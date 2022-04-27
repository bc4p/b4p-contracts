from brownie import accounts,Contract, network, config, Market,config, EnergyToken, ProducingAsset, ConsumingAsset, MockEursToken
from scripts.helper import get_account, get_contract, generate_accounts, get_latest_accounts
from web3 import Web3
from time import time
import json 
zero_address = "0x0000000000000000000000000000000000000000"

def print_balances(eurs):
    market = Market[-1]
    enrgyToken = EnergyToken[-1]
    powerplant = ProducingAsset[-1]
    house = ConsumingAsset[-1]
    print("\neurs:")
    print(f'EURS house {eurs.balanceOf(house)}')
    print(f'EURS powerplant {eurs.balanceOf(powerplant)}')
    print(f'EURS market {eurs.balanceOf(market)}')
    print("\nenergy token:")
    print(f'EnergyTokens bidder {enrgyToken.balanceOf(house,1)}')
    print(f'EnergyTokens offerer {enrgyToken.balanceOf(powerplant,1)}')
    print(f'EnergyTokens market {enrgyToken.balanceOf(market,1)}\n')



def getEURS():
    eurs_address = config["networks"][network.show_active()].get("eurs")
    eurs = Contract.from_explorer(eurs_address)
    return eurs

def getMockEURS():
    return MockEursToken.deploy(accounts[0], {"from":accounts[0]})

def fundEURS(eurs, account):
    tx = eurs.transfer(account, 1000, {"from":eurs})
    tx.wait(1)

def fundMockEURS(account):
    MockEursToken[-1].createTokens(1000, {"from":accounts[0]})
    MockEursToken[-1].transferFrom(accounts[0], account, 1000, {"from":accounts[0]})





def main():
    print("\n############### SETUP TRANSACTIONS ###############\n")

    eurs = getEURS()
    #deployments
    energyToken = EnergyToken.deploy("url", {"from":accounts[0]})
    market = Market.deploy(eurs,energyToken,zero_address,1, {"from":accounts[1]})
    powerplant = ProducingAsset.deploy(market, {"from":accounts[2]})
    house = ConsumingAsset.deploy(market, {"from":accounts[3]})
    fundEURS(eurs, house)
    fundEURS(eurs, powerplant)
    print(f"eurs house: {eurs.balanceOf(house)}")
    market = Market[-1]
    
    enrgyToken = EnergyToken[-1]

    #approve Market to use tokens
    eurs.approve(market, 2**200, {"from":house})
    #enrgyToken.approve(market, 2*200, {"from":accounts[1]})

    print(f'allowance:{eurs.allowance(accounts[3], market)}')

    print("\n############### MARKET TRANSACTIONS ###############\n")
    print_balances(eurs)

    tx = house.createBid(35, 10, {"from":accounts[3]})
    tx.wait(1)
    print(tx.events)
    print_balances(eurs)

    tx = powerplant.createOffer(20, 100, {"from":accounts[2]})
    tx.wait(1)
    print(tx.events)
    print_balances(eurs)
    #tx = market.receiveOffer(3, 1000, {"from": accounts[1]})
    #tx.wait(1)
    #print(tx.events)
    #print_balances(eurs)

    
    #tx = market.receiveBid(5, 10, {"from": accounts[0]})
    #tx.wait(1)
    #print(tx.events)
    #print_balances(eurs)

   
