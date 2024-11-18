#!/bin/bash

# bash block-hijacking-attack/utils/clean_utxo.sh 2 0.0002

# Helps consolidate dispersed funds into a single transaction

export HOME="$HOME/liquid"

node_num=$1
amount=$2

for i in {1..100}; do
    # Send to address from node_num
    elements-cli -datadir=$HOME/elementsdir$node_num sendtoaddress $(elements-cli -datadir=$HOME/elementsdir$node_num getnewaddress) $amount

    # List unspent transactions and get the length (number of unspent transactions)
    elements-cli -datadir=$HOME/elementsdir$node_num listunspent | jq "length"
done
