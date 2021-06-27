#!/bin/bash

function header {
	echo "usage: ./fetch_storage [contract_id]"
	echo "0 -> bifrost contract"
	echo "1 -> FA12 contract"
}

if [[ "$#" !=  "1" ]]
then
	echo "Error: expects 1 argument"
	header
	exit 1
fi

if [[ "$1" == "0" ]]
then
	tezos-client get contract storage for "$(cat ../contract_addr/bifrost.txt)"
elif [[ "$1" == "1" ]]
then
	tezos-client get contract storage for "$(cat ../contract_addr/fa12.txt)"
else
	echo "Error: expects 0 or 1 in argument, got $1"
	header
	exit 1
fi


