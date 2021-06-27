#!/bin/bash

#echo "minting.."
tezos-client transfer 0 from alice to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Left (Pair \"$(cat ../keys/bob_pub.txt)\" 12))))" --burn-cap 0.0185
echo "..send_to_cosmos"
tezos-client -w 15 transfer 0 from bob to "$(cat ../contract_addr/fa12.txt)" --fee 1 --arg "(Right (Left (Right (Left (Pair (Pair 5 \"cosmos_chain\") (Pair \"cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88\" (Pair \"tezos_chain\" \"$(cat ../keys/bob_pub.txt)\")))))))" --burn-cap 0.04525
# echo "approve alice"
# tezos-client transfer 0 from bob to "$(cat ./contract_addr/fa12.txt)" --fee 1 --arg "(Left (Left (Left (Pair \"$(cat ./keys/alice_pub.txt)\" 5))))" --burn-cap 0.00775
