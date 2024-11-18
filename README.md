# Block Hijacking Attack

### How to perform
1. Measure the time required for one transaction to be issued by a legitimate user and added to the blockchain under normal network conditions
    - `bash block-hijacking-attack/legitimate_tx.sh 1`
2. The largest transaction UTXO will be split into hundreds of UTXOs with the required amount of balance to perform this attack.
    - `bash block-hijacking-attack/utils/split_fund.sh 2`
3. Perform Block Hijacking Attack
    - `bash block-hijacking-attack/attack.sh 2`
4. Check the last block's condition with the following commands
    - `liquidnode01-cli getblock $(liquidnode01-cli getbestblockhash) | jq ".weight" | awk '{ print $1 / 1000000 }'`
5. Once the last block is fulled with attacker's TXs, check the time for the legitimate TX again to see if the attack successfully performs.
    - `bash block-hijacking-attack/legitimate_tx.sh 1`
    -note: there should be no space for even one transaction in the block