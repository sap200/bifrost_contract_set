# bifrost_contract_set

<p align="center">
  <img src="./bifrost_contract.png" />
</p>

This is a repo containing bifrost contract set that needs to be deployed in tezos to connect it to cosmos ecosystem using a pegzone called bifrost zone

## Installation

```
$ git clone github.com/sap200/bifrost_contract_set

$ cd bifrost_contract_set

$ chmod +x setup.bash

$ ./setup.bash
```

## Usage

Navigate to commands directory in bifrost_contract_set

```
$ cd commands
$ ls

fa12send.bash  fetch_bigmaps.bash  fetch_storage.bash  send_to_cosmos.bash
```
#### Send to cosmos the tezos token from tezos-blockchain

```
gedit send_to_cosmos.bash

#!/bin/bash

tezos-client transfer 100 from alice to "$(cat ../contract_addr/bifrost.txt)" --fee 1 --arg "(Left (Right (Pair \"mars\" (Pair \"cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88\" \"tezos_chain\"))))" --burn-cap 0.05475
```

Edit sender and amount if you want to and the cosmos receiver address, Tx fails if cosmos receiver is wrong.
save file

```
$ chmod +x send_to_cosmos.bash
$ ./send_to_cosmos.bash

usage ./send_to_cosmos [cosmos_receiver] [amount] [tezos_sender]

$ ./send_to_cosmos cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88 100 alice

```

#### send FA12 tokens to cosmos

```
gedit fa12send.bash

#!/bin/bash

#echo "minting.."
tezos-client transfer 0 from alice to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Left (Pair \"$(cat ../keys/bob_pub.txt)\" 12))))" --burn-cap 0.0185
echo "..send_to_cosmos"
tezos-client -w 15 transfer 0 from bob to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Right (Left (Pair (Pair 5 \"cosmos_chain\") (Pair \"cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88\" (Pair \"tezos_chain\" \"$(cat ../keys/bob_pub.txt)\")))))))" --burn-cap 0.04525
# echo "approve alice"
# tezos-client transfer 0 from bob to "$(cat ./contract_addr/fa12.txt)" --fee 1 --arg "(Left (Left (Left (Pair \"$(cat ./keys/alice_pub.txt)\" 5))))" --burn-cap 0.00775
```

step a is minting token since you originate contract there's

```
tezos-client transfer 0 from alice to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Left (Pair \"$(cat <<Your tezos address file path>>)\" <<amount>>))))" --burn-cap 0.0185
echo "..send_to_cosmos"
```

step b is sending it 

```
tezos-client -w 15 transfer 0 from bob to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Right (Left (Pair (Pair <<Amount to send>> \"cosmos_chain\") (Pair \"<<cosmos_address>>\" (Pair \"tezos_chain\" \"$(cat <<path to your tezos address file>>)\")))))))" --burn-cap 0.04525
```

Note: Instead of path you can directly provide your tezos address

```
tezos-client -w 15 transfer 0 from bob to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Right (Left (Pair (Pair <<Amount to send>> \"cosmos_chain\") (Pair \"<<cosmos_address>>\" (Pair \"tezos_chain\" \"<<tezos_address>>\")))))))" --burn-cap 0.04525
```

After editing
```
$ chmod +x fa12send.bash
$ ./fa12send.bash cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88
```

or in new version

```
$ ./fa12send.bash [cosmos_receiver]
$ ./fa12send.bash 
```

#### Fetch the contract address

```
$ chmod +x fetch_storage
$ ./fetch_storage

Error: expects 1 argument
usage: ./fetch_storage [contract_id]
0 -> bifrost contract
1 -> FA12 contract
```

For Bifrost contract storage provide 0 as argument

```
./fetch_storage 0

output:

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Pair (Pair 0 {} 0) 1 0 "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"

```

For Fa12 contract storage provide 1 as argument

```
./fetch_storage 1

output:

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Pair (Pair (Pair "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" 2) 0 3) (Pair False {}) 4 0
```

#### Fetch Bigmaps

Bigmaps are used to store balance in FA12, locked amount and unlocked amount in bifrost contract
They are lazy to be serialized by command and hence doesn't appears while fetching storage.
And them not appearing also makes tezos processing engine easy to implement

```
./fetch_bigmaps.bash 

output: 

usage: ./fetch_bigmaps [contract] [big_map_value] [map_key]

contract ----> 0 for bifrost, 1 for Fa12
big_map_value -----> accounts for big_map_account, locker for big_map_locker, balance for fa12_balance
map_key ----> alice for alice, bob for bob

```

For fetching account balances of alice [by default alice and bob are 2 keys in sandbox. Program can be modified for any address]

```
./fetch_bigmaps.bash 0 accounts alice
```

For fetching locked amount of alice. [Locked amount doesn't gets updated however the total locker balance gets updated, locker represents all amounts locked till now.]

After sending 100 tezos to cosmos
locker balance of alice is 100

```
./fetch_bigmaps.bash 0 locker alice

output:

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

100000000

```

For fetching Fa12 balance of alice

7 is balance after minting 12 tokens and sending 5 to cosmos from alice

```
./fetch_bigmaps 1 balance alice

output:
Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Pair {} 7
```

Note: Initially when no addresses are registered in bigmap because no txs has taken place from that account, you might get an error like shown
It doesn't mean program crashed but is generated because there is no such address in bigmap

```
Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Warning:
  
                 This is NOT the Tezos Mainnet.
  
           Do NOT use your fundraiser keys on this network.

Error:
  Did not find service: POST http://localhost:20000/chains/main/blocks/head/context/big_maps/0/exprtr3iA2ZhFDtnJZDS1nVxJYeXGWw2AWziVAD7DZf7kxsHmNLZBB/normalized
```

## Tezos-client

Bash scripts are automated versions using tezos-client under the hood. For more details about tezos-client visit

- [tezos-client](https://assets.tqtezos.com/docs/setup/1-tezos-client/)

- [tezos-client manual](https://tezos.gitlab.io/shell/cli-commands.html)



