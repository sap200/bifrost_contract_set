#!/bin/bash

# run docker sandbox for tezos
echo "opening docker sandbox..."
echo "---------------------------------"
echo ""
docker run --rm --name my-sandbox --detach -p 20000:20000 tqtezos/flextesa:20210602 flobox start
sleep 7

# configure the tezos-client
echo "configuring tezos client ..."
echo "---------------------------------"
echo ""
tezos-client --endpoint http://localhost:20000 bootstrapped
tezos-client --endpoint http://localhost:20000 config update

# Get the key and import
echo "getting account info..."
echo "---------------------------------"
echo ""
docker run --rm tqtezos/flextesa:20210602 flobox info
docker run --rm tqtezos/flextesa:20210602 flobox info 1>& keys_info.txt

if [[ ! -d "./keys" ]]
then 
	mkdir keys
fi

cat keys_info.txt | grep "unencrypted" | head -n 1 | awk '{print $2}' 1>& ./keys/alice_private.txt
cat keys_info.txt | grep "unencrypted" | tail -n 1 | awk '{print $2}' 1>& ./keys/bob_private.txt
cat keys_info.txt | grep tz | head -n 1 | awk '{print $2}' 1>& ./keys/alice_pub.txt
cat keys_info.txt | grep tz | tail -n 1 | awk '{print $2}' 1>& ./keys/bob_pub.txt
	
rm keys_info.txt

# Import the keys to tezos-client
tezos-client import secret key alice $(cat ./keys/alice.txt) --force
tezos-client import secret key bob $(cat ./keys/bob.txt) --force

# Testing if keys are added by getting the balance
echo "testing by getting balance..."
echo "---------------------------------"
echo ""
tezos-client get balance for alice
tezos-client get balance for bob

echo "deploying bifrost contract and returning contract address..."
echo "--------------------------------------------------------"
echo ""
tezos-client originate contract bifrost transferring 0 from alice running ./contracts/bifrost.tz --fee 1 --force --init "(Pair (Pair {} (Pair {} 0)) (Pair {} (Pair 0 \"$(cat ./keys/alice_pub.txt)\")))"  --burn-cap 0.755 1>& bifrost_contract.txt

echo "Writing contract address to ./contract_addr/bifrost_contract.txt"
echo ""

if [[ ! -d "./contract_addr" ]]
then 
	mkdir contract_addr
fi

cat bifrost_contract.txt | grep "New contract" | awk '{print $3}' 1>& ./contract_addr/bifrost.txt
rm bifrost_contract.txt

echo "deploying fa12 contract and returning contract address..."
echo "---------------------------------------------------------"
echo ""

tezos-client originate contract fa12 transferring 0 from alice running ./contracts/fa12.tz --fee 1 --force --init "(Pair (Pair (Pair \"$(cat ./keys/alice_pub.txt)\" {}) (Pair 0 {Elt \"\" 0x697066733a2f2f516d616941556a3146464e4759547538724c426a633365654e3963534b7761463845474d424e446d687a504e4664})) (Pair (Pair False {}) (Pair {Elt 0 (Pair 0 {Elt \"decimals\" 0x3138; Elt \"icon\" 0x68747470733a2f2f736d61727470792e696f2f7374617469632f696d672f6c6f676f2d6f6e6c792e737667; Elt \"name\" 0x4d7920477265617420546f6b656e; Elt \"symbol\" 0x4d4754})} 0)))" --burn-cap 1.61375 1>& fa12_contract.txt

echo "writing contract address to ./contract_addr/fa12_contract.txt"
cat fa12_contract.txt | grep "New contract" | awk '{print $3}' 1>& ./contract_addr/fa12.txt
rm fa12_contract.txt

