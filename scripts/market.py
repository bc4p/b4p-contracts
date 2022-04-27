from brownie import accounts,Contract, network, config, Market, MarketRegistry, config, EnergyToken, ProducingAsset, ConsumingAsset, MockEursToken
from scripts.utils.print_utils import *

from scripts.helper import get_account, get_contract, generate_accounts, get_latest_accounts
from web3 import Web3
from time import time
import json 
import pprint

zero_address = "0x0000000000000000000000000000000000000000"
NAMES = ["Neighborhood 1", "Neighborhood 2", "Grid", "House 1", "House 2"]


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
    registry = MarketRegistry.deploy({"from":accounts[6]})
    energyToken = EnergyToken.deploy("url", {"from":accounts[0]})

    #deploy market nodes
    neighborhood1 = Market.deploy(eurs,energyToken,zero_address,zero_address,registry,1, {"from":accounts[1]})
    neighborhood2 = Market.deploy(eurs,energyToken,zero_address,zero_address,registry,1, {"from":accounts[2]})
    grid = Market.deploy(eurs,energyToken,zero_address,zero_address,registry,2, {"from":accounts[3]})
    house1 = Market.deploy(eurs,energyToken,neighborhood1,zero_address,registry,0, {"from":accounts[4]})
    house2 = Market.deploy(eurs,energyToken,zero_address,neighborhood2,registry,0, {"from":accounts[5]})

    #establish remaining connections
    tx = neighborhood1.setMarkets(grid,house1, {"from":accounts[1]})
    tx.wait(1)
    tx = neighborhood2.setMarkets(house2, grid, {"from":accounts[2]})
    tx.wait(1)
    tx = grid.setMarkets(neighborhood1, neighborhood2, {"from":accounts[3]})
    tx.wait(1)

    #deploy energy assets
    powerplant = ProducingAsset.deploy(house2,registry, {"from":accounts[6]})
    load = ConsumingAsset.deploy(house1,registry, {"from":accounts[7]})

    #fund energy assets
    fundEURS(eurs, load)
    fundEURS(eurs, powerplant)

    print("\n############### MARKET TRANSACTIONS ###############\n")
    print(f"powerplant: {powerplant}")
    print(f"load: {load}")
    print(f"house1: {house1}")
    print(f"house2: {house2}")
    print(f"neighborhood1: {neighborhood1}")
    print(f"neighborhood2: {neighborhood2}")
    print(f"grid: {grid}")
    print()
    print(f"powerplant markets: {powerplant.market1()} || {powerplant.market2()}")
    print(f"load markets: {load.market1()} || {load.market2()}")
    print(f"house1 markets: {house1.market1()} || {house1.market2()}")
    print(f"house2 markets: {house2.market1()} || {house2.market2()}")
    print(f"neighborhood1 markets: {neighborhood1.market1()} || {neighborhood1.market2()}")
    print(f"neighborhood2 markets: {neighborhood2.market1()} || {neighborhood2.market2()}")
    print(f"grid markets: {grid.market1()} || {grid.market2()}")
    print()
    # print_balances(eurs)

    # print(market2.bids(0))
    tx = load.createBid(30, 1, {"from":accounts[7]})
    tx.wait(1)
    print(tx.call_trace())
    printBidsAndOffers(NAMES)

    print_balances(NAMES, eurs)
    #pprint.pprint(tx.events)

    # print(house)
    # print(market2.bids(0))
    # print(powerplant)
    # print(market2)

    # print(tx.events)

    tx = powerplant.createOffer(10, 1, {"from":accounts[6]})
    tx.wait(1)
    #print(tx.events)
    print(tx.call_trace())
    printBidsAndOffers(NAMES)
    print_balances(NAMES, eurs)

    tx = house1.forwardBid(0, {"from":accounts[4]})
    tx.wait(1)
    print(tx.call_trace())
    printBidsAndOffers(NAMES)


    tx = house2.forwardOffer(0, {"from":accounts[5]})
    tx.wait(1)
    print(tx.call_trace())
    #print(tx.events)
    printBidsAndOffers(NAMES)
    print_balances(NAMES, eurs)

    tx = neighborhood1.forwardBid(0, {"from": accounts[6]})
    tx.wait(1)
    printBidsAndOffers(NAMES)
    print(tx.call_trace())

    tx = neighborhood2.forwardOffer(0, {"from": accounts[7]})
    tx.wait(1)
    print(tx.call_trace())
    printBidsAndOffers(NAMES)
    print_balances(NAMES, eurs)


    #tx = market.receiveOffer(3, 1000, {"from": accounts[1]})
    #tx.wait(1)
    #print(tx.events)
    #print_balances(eurs)

    
    #tx = market.receiveBid(5, 10, {"from": accounts[0]})
    #tx.wait(1)
    #print(tx.events)
    #print_balances(eurs)

   
