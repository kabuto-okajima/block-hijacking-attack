#!/bin/bash

# bash block-hijacking-attack/utils/split_fund.sh 2

# The largest transaction UTXO will be split into 1000 UTXOs with the required amount of balance.

export HOME="$HOME/liquid"

node_num=$1

target_num_UTXO=1000

send_amount=0.001 # each transaction will have this amount
min_amount=0.01   # the sender must have this amount of balance
num_addresses=13  # the number of reciepents of each transaction

while true; do
    # List unspent transactions that have amount >= send_amount
    utxo_above_min=$(elements-cli -datadir=$HOME/elementsdir$node_num listunspent | jq '[.[] | select(.amount >= '"$send_amount"')]')
    unspent_num=$(echo "$utxo_above_min" | jq "length")

    echo "UTXOs with amount >= $send_amount: $unspent_num"

    # Check if the number of UTXOs has reached target_num_UTXO
    if [ "$unspent_num" -ge "$target_num_UTXO" ]; then
        echo "UTXO count has reached the target. Exiting..."
        break
    fi

    # Get the unspent transaction with the largest amount
    utxo=$(elements-cli -datadir=$HOME/elementsdir$node_num listunspent | jq -r 'max_by(.amount) | if . == null then empty else .txid + " " + (.vout|tostring) + " " + (.amount|tostring) end')

    # If any UTXO unvariable, pause for 60 seconds
    if [ -z "$utxo" ]; then
        echo "No UTXO found. Pausing for 60 seconds..."
        sleep 60
        continue
    fi

    txid=$(echo $utxo | cut -d' ' -f1)
    vout=$(echo $utxo | cut -d' ' -f2)
    amount=$(echo $utxo | cut -d' ' -f3)

    # Check if UTXO amount is below the minimum threshold
    if (($(echo "$amount < $min_amount" | bc -l))); then
        echo "The found TX with the largest amount is: $utxo"
        echo "UTXO amount ($amount) is below the minimum threshold ($min_amount)."

        # Wait seconds
        echo "Waiting 5 seconds for the new block"
        sleep 5
        continue
    fi

    # Initialize the raw transaction input
    recipients="["
    for ((j = 1; j <= num_addresses; j++)); do
        # Get a new address
        address=$(elements-cli -datadir=$HOME/elementsdir$node_num getnewaddress)

        # Append the address and amount to the raw transaction input
        if [ $j -eq $num_addresses ]; then
            recipients+="{\"$address\":$send_amount}"
        else
            recipients+="{\"$address\":$send_amount},"
        fi
    done
    recipients+="]"

    # Create a raw transaction
    rawtx=$(elements-cli -datadir=$HOME/elementsdir$node_num createrawtransaction "[{\"txid\":\"$txid\",\"vout\":$vout}]" "$recipients")

    # Fund the transaction
    fundedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num fundrawtransaction $rawtx | jq -r '.hex')

    # Blind the transaction
    blindedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num blindrawtransaction $fundedtx)

    # Sign the transaction
    signedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num signrawtransactionwithwallet $blindedtx | jq -r '.hex')

    # Send the transaction
    txid=$(elements-cli -datadir=$HOME/elementsdir$node_num sendrawtransaction $signedtx)

    echo "txid: $txid"

    # Wait for block creation
    sleep 60
done
