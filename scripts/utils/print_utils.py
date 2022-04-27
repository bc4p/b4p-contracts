from brownie import  Market, EnergyToken, ProducingAsset, ConsumingAsset


def printBidsAndOffers(names):
    offers = []
    bids = []
    counter = 0
    for market in Market:
        offer_temp = market.offers(0)
        bid_temp = market.bids(0)

        offer = offer_temp
        bid = bid_temp

        if offer_temp[0] == 0:
            offer = "no offer"
        if bid_temp[0] == 0:
            bid = "no bid"

        print(f"{names[counter]} \n\t offer: {offer} \n\t bid: {bid} ")
        counter += 1

def print_balances(names, eurs):
    eurs_balances = []
    energy_balance = []
    enrgyToken = EnergyToken[-1]

    counter = 0
    for market in Market:
        eurs_balances.append(f"EURS {names[counter]}= {eurs.balanceOf(market)}")
        #energy_balance.append(f"EnergyTokens {NAMES[counter]}= {enrgyToken.balanceOf(market,1)}")
        counter += 1

    counter = 0
    for producing in ProducingAsset:
        eurs_balances.append(f"EURS Producing Asset_{counter}= {eurs.balanceOf(producing)}")
        energy_balance.append(f"EnergyTokens Producing_Asset_{counter}= {enrgyToken.balanceOf(producing,1)}")
        counter +=1

    counter = 0
    for consuming in ConsumingAsset:
        eurs_balances.append(f"EURS Consuming_Asset_{counter}= {eurs.balanceOf(consuming)}")
        energy_balance.append(f"EnergyTokens Consuming_Asset_{counter}= {enrgyToken.balanceOf(consuming,1)}")
        counter +=1


    for eur_bal in eurs_balances:
        print(eur_bal)
    print("\n")
    for en_bal in energy_balance:
        print(en_bal)


