# Block Hijacking Attack

### How to perform this attack
1. Measure the time required for a transaction to be issued by a legitimate user and added to the blockchain under normal network conditions
    - `bash block-hijacking-attack/legitimate_tx.sh 1`
2. The largest transaction UTXO will be split into 200 UTXOs with the required amount of balance.
    - `bash block-hijacking-attack/utils/split_fund.sh 2`
3. Perform Block Hijacking Attack
    - `bash block-hijacking-attack/attack.sh 2`


### memo 
1. (`split_fund.sh`) Split the largest transaction into 200 transactions with sufficient fund.
    - (each attack transaction: 0.00004 BTC + fee) x (the number of minutes attacker takes)

2. (`attack.sh`) Sort unspent transactions by "amount"

3. issue the transaction and send

4. repeat 2-3 step
