#!/bin/bash

# bash block-hijacking-attack/utils/total_fee.sh 2

export HOME="$HOME/liquid"

# File where txids are saved
txid_file="txids.txt"
total_fee=0
transaction_count=0 # Initialize transaction counter

node_num=$1

# Read each txid line by line from the file
while IFS= read -r txid; do
    # Retrieve transaction information
    tx_info=$(elements-cli -datadir=$HOME/elementsdir$node_num gettransaction $txid)

    # Extract the fee from the JSON output
    fee=$(echo $tx_info | jq -r '.fee.bitcoin')

    # Convert fee to positive (absolute) numeric value
    fee_positive=$(printf "%.10f" "$(echo "$fee" | awk '{print ($1 < 0) ? -$1 : $1}')")

    # Accumulate the fee to get the total
    total_fee=$(echo "$total_fee + $fee_positive" | bc -l)

    # Increment the transaction counter
    transaction_count=$((transaction_count + 1))

    # Display the fee for each transaction
    echo "Transaction ID: $txid, Fee: $fee_positive BTC"
done <"$txid_file"

# Display the total fee paid and transaction count
echo "Total fee paid: $(echo "$total_fee" | awk '{print ($1 < 0) ? -$1 : $1}') BTC"
echo "Total transactions processed: $transaction_count"
