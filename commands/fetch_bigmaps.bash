#!/bin/bash

# Function for header
function header {
	echo ""
	echo "usage: ./fetch_bigmaps [contract] [big_map_value] [map_key]"
	echo ""
	echo "contract ----> 0 for bifrost, 1 for Fa12"
	echo "big_map_value -----> accounts for big_map_account, locker for big_map_locker, balance for fa12_balance"
	echo "map_key ----> alice for alice, bob for bob"
	echo ""
}

# Function for executing command
function execute {
	
	if [[ "$3" == "alice" ]]
	then
		# find hash 
		alice=$(tezos-client hash data \"$(cat ../keys/alice_pub.txt)\" of type address | grep expr | awk '{print $2}' | head -n 1)
		# fetch hash 
		# echo "$alice"
		tezos-client get element "$alice" of big map "$2"
		
	elif [[ "$3" == "bob" ]]
	then
		# find hash
		bob=$(tezos-client hash data \"$(cat ../keys/bob_pub.txt)\" of type address | grep expr | awk '{print $2}' | head -n 1)
		
		# fetch hash
		tezos-client get element "$bob" of big map "$2"
		
	else
		echo "Invalid map_key, accepts alice or bob"
		exit 1
	fi
}

# check argument length
if [[ "$#" != "3" ]]
then
	echo "Error: Invalid arguments"
	header
	exit 1
fi

if [[ "$1" == "0" ]]
then 
	if [[ "$2" == "accounts" ]]
	then
		# execute system command for big map
		execute "$1" "0" "$3"
		
	elif [[ "$2" == "locker" ]]
	then
		# execute system command for big map
		execute "$1" "1" "$3"
		
	else
		echo "Error: No big maps of type" 
		exit 1
	fi	
elif [[ "$1" == 1 ]]
then
	if [[ "$2" == "balance" ]]
	then
		# execute system command for big map
		execute "$1" "2" "$3"
	else
		echo "Error: No big maps of type"
		exit 1
	fi
else 
	echo "Error: Invalid arguments"
	header
	exit 1
fi

