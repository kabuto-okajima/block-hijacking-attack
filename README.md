# Block Hijacking Attack

## What it is
> K. Okajima, S. Matsuo, K. Chida,  
> **“Block Hijacking Attack: Impact Evaluation on Liquid Network and Design Insights for Blockchain-based Scaling Solutions.”**  
> IEEE ICBC 2025. DOI: 10.1109/ICBC64466.2025.11114534

This repository serves as a concise memo of our reproduction notes—procedures and configurations—for the “Block Hijacking Attack,” conducted **in collaboration with Liquid Network developers** on a **safely isolated test network**. It is not intended for production use.

## Scope and Context
- **Network**: Local, isolated test network (Elements/Bitcoin regtest–based).
- **Collaboration**: Environment and operation reviewed with Liquid Network developers.
- **Purpose**: Capture minimal steps and observations required to recall and re-run the experiments.

## Reproduction Procedure
1. **Baseline latency measurement (legitimate transaction)**
   - Purpose: Measure the time for a legitimate user’s transaction to be issued and included under normal conditions.
   - Command:
     ```bash
     bash legitimate_tx.sh 1
     ```

2. **UTXO preparation (fan-out)**
   - Purpose: Split the largest available UTXO into hundreds of smaller UTXOs sufficient to fund the attack pattern.
   - Command:
     ```bash
     bash utils/split_fund.sh 2
     ```

3. **Execute the Block Hijacking attack**
   - Purpose: Submit attacker transactions as configured to saturate block capacity.
   - Command:
     ```bash
     bash attack.sh 2
     ```

4. **Inspect the latest block**
   - Purpose: Verify block utilization (e.g., near the protocol’s maximum weight).
   - Command:
     ```bash
     liquidnode01-cli getblock $(liquidnode01-cli getbestblockhash) | jq ".weight" | awk '{ print $1 / 1000000 }'
     ```

5. **Post-attack latency measurement (legitimate transaction)**
   - Purpose: Re-measure inclusion time to confirm the attack’s impact.
   - Commands:
     ```bash
     bash legitimate_tx.sh 1
     ```
   - Note: The most recent block should be saturated; there should be no capacity for even a single additional transaction.

