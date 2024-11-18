#!/bin/bash

# bash block-hijacking-attack/legitimate_tx.sh 1

# - Measure time required for one TX to be confirmed under normal network conditions
# - Issue one transaction and check confirmations every {check_interval} seconds

export HOME="$HOME/liquid"

node_num=$1
minimum_amount=0.00004

# Interval duration in seconds
check_interval=5

# Get Receiver Address
address=$(elements-cli -datadir=$HOME/elementsdir$node_num getnewaddress)

# Send the transaction and capture the TXID
tx_id=$(elements-cli -datadir=$HOME/elementsdir$node_num sendtoaddress $address $minimum_amount)
echo "Transaction issued. TX ID: $tx_id"

elapsed_time=0

# Start checking confirmations every 5 seconds
while true; do
    # Get TX info
    raw_tx_info=$(elements-cli -datadir=$HOME/elementsdir$node_num gettransaction $tx_id true 2>&1)

    # Check if transaction exists or an error is returned
    if echo "$raw_tx_info" | grep -q "error code:"; then
        echo "Transaction $tx_id is not yet confirmed or has not been broadcasted. Retrying in $check_interval seconds..."
    else
        # Extract the number of confirmations
        confirmations=$(echo "$raw_tx_info" | jq ".confirmations")

        # Output the current number of confirmations
        echo "Transaction $tx_id has $confirmations confirmation(s)."

        # If the transaction is confirmed, exit the loop
        if [ "$confirmations" -gt 0 ]; then
            echo "Transaction is confirmed in a block with $confirmations confirmation(s)."
            break
        fi
    fi

    # Wait for the specified interval before checking again
    sleep $check_interval

    # Update and log the elapsed time
    elapsed_time=$((elapsed_time + check_interval))
    echo "$elapsed_time seconds passed."
done
