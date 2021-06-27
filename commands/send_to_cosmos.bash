#!/bin/bash

tezos-client transfer 100 from alice to "$(cat ../contract_addr/bifrost.txt)" --fee 1 --arg "(Left (Right (Pair \"mars\" (Pair \"cosmos1j5pz7cp5w6wr65z47azefzygcevqssrguccc88\" \"tezos_chain\"))))" --burn-cap 0.05475
