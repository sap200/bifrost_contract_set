# This is a smart contract for bridging tezos to cosmos
'''
This is a smart contract called magnet_bridge and it connects,
tezzos with cosmos. This is a primitive prototype and hence all 
the checks may not be done but it shows it is possible...

'''

import smartpy as sp
import time

# status codes
Initiated = 'Initiated'
Pending = 'Pending'
Failed = 'Failed'
Success = 'Success'



class bifrost(sp.Contract):
    # init function defines the initial parameters to hold values
    def __init__(self, _owner):
        self.init_storage(
            accounts=sp.big_map(tkey=sp.TAddress, tvalue=None),
            cosmos_send=sp.map(tkey=sp.TInt, tvalue=None),
            locker=sp.big_map(tkey=sp.TAddress, tvalue=sp.TMutez),
            owner=_owner,
            counter=sp.int(0),
        )
        
 
    # send money to the contract
    @sp.entry_point
    def send_amount(self):
        # check sender is amount is > 0
        sp.verify(sp.amount > sp.mutez(0), "amount is less than or equal to zero")
        # check if sender address in account_and_balance
        sp.if self.data.accounts.contains(sp.sender):
            self.data.accounts[sp.sender] += sp.amount
        sp.else:
            # do something
            self.data.accounts[sp.sender] = sp.amount
            
    
    @sp.entry_point
    def withdraw(self):
        # check if sender is not empty
        sp.verify(self.data.accounts.contains(sp.sender), "You don't own any funds here")
        sp.verify(self.data.accounts[sp.sender] >= sp.amount, "requested amount more than balance")
        # send money to the sender
        sp.send(sp.sender, sp.amount)
        # deduct money from the balance
        self.data.accounts[sp.sender] -= sp.amount
            
    
    # send money to the cosmos chain
    @sp.entry_point        
    def send_to_cosmos(self, _receiver, _src_chain, _dest_chain):
        # check if sender field is empty 
        sp.verify(sp.amount != sp.mutez(0), "sending amount is 0")
        
        # add the required money to the locker
        sp.if self.data.locker.contains(sp.sender):
            self.data.locker[sp.sender] += sp.amount
        sp.else:
            self.data.locker[sp.sender] = sp.amount
            
        # add a txs in the cosmos_send array
        # 3 tx status
        # initiated, pending, success, failed
        _tx_id = sp.local('_tx_id', self.data.counter)
        record = sp.record(tx_id=_tx_id.value, tz_sender=sp.sender, cosmos_receiver=_receiver, amount=sp.amount, src_chain=_src_chain, dest_chain=_dest_chain, tx_status=Initiated, time_stamp=sp.timestamp(int(time.time())))
        self.data.counter += 1
        
        # push data
        self.data.cosmos_send[_tx_id.value] = record
        
    @sp.entry_point
    def update_tx_status(self, _tx_id, _status):
        sp.verify(sp.sender == self.data.owner)
        # check status
        sp.if _status == Success:
            del self.data.cosmos_send[_tx_id]
        sp.else:
            # unlock the amount
            _address = self.data.cosmos_send[_tx_id].tz_sender
            # amount to be unlocker
            amt = sp.local('amt', self.data.locker[_address])
            self.data.locker[_address] = sp.mutez(0)
            # check and update locker
            sp.if self.data.accounts.contains(_address):
                self.data.accounts[_address] = amt.value
                del self.data.cosmos_send[_tx_id]
            sp.else:
                self.data.accounts[_address] = amt.value
                del self.data.cosmos_send[_tx_id]
            
        
        
        
@sp.add_test(name='bifrost_portal_test')
def test():
    scenario = sp.test_scenario()
    owner = sp.address('tz1owner')
    alice = sp.address('tz1alice')
    c = bifrost(_owner=owner)
    scenario += c
    
    # Test function1 send_money
    c.send_amount().run(sender=alice, amount=sp.tez(100))
    
    # withdraw
    c.withdraw().run(sender=alice, amount=sp.tez(100))
    
    c.send_to_cosmos(_receiver="cosmos1abdeffesaeddfnawidnniee", _src_chain="tezos_chain", _dest_chain="mars").run(sender=alice, amount=sp.tez(100))
    
    c.send_to_cosmos(_receiver="cosmos1abdeffesaeddfnawidnniee", _src_chain="tezos_chain", _dest_chain="mars").run(sender=alice, amount=sp.tez(100))
    
    c.send_to_cosmos(_receiver="cosmos1abdeffesaeddfnawidnniee", _src_chain="tezos_chain", _dest_chain="mars").run(sender=alice, amount=sp.tez(100))
    
    c.update_tx_status(_tx_id=0, _status=Failed).run(sender=owner)
    scenario.h2("Data")
    
    # # withdraw fails as amount is locked
    # c.withdraw().run(sender=alice, amount=sp.tez(100))
    
    
sp.add_compilation_target('bifrost_portal', bifrost(_owner="tz1owner"))
            
            
        
        
