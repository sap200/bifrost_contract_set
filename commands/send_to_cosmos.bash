#!/bin/bash

if [[ "$#" != 3 ]]
then
	echo "usage ./send_to_cosmos [cosmos_receiver] [amount] [tezos_sender]"
	exit 1
fi

tezos-client transfer "$2" from "$3" to "$(cat ../contract_addr/bifrost.txt)" --fee 1 --arg "(Left (Right (Pair \"mars\" (Pair \"$1\" \"tezos_chain\"))))" --burn-cap 0.088
