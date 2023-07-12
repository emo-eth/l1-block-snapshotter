# L1BlockSnapshotter

## Overview

OP Stack chains have an [L1Block](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/L2/L1Block.sol) smart contract that makes information about the latest L1 block accessible to L2 smart contracts. This information is not historical, and is updated each epoch (each L1 block).

This smart contract merely snapshots the current L1 block information and allows retrieval of that information at a later time. This is useful for applications that need to make assertions about the L1 state at a given block on the L2.

## Potential Use Cases
- PBTs on L2s
  - [EIP-5791](https://eips.ethereum.org/EIPS/eip-5791) uses a signature of a message containing a recent blockhash to permit transfers of Physical Backed Tokens (PBTs). In an L1 context, this works because the 256 most recent blockhashes are available to the EVM, and blocks are produced at a slow enough cadence that network latency should not be an issue. In an L2 context, this is not necessarily the case. The L1BlockSnapshotter allows for the creation of a snapshot of the L1 blockhashes for historical retrieval on L2. It also prevents relying on a value that may be manipulated by a centralized sequencer (assuming the L2 still accurately records L1 blockhashes)
- L1 State Proofs
  - The L1BlockSnapshotter acts as a central, ownerless source of truth for historical L1 block information. This means any user or smart contract can create a snapshot of current L1 Block metadata and make it available to other applications. This can be used in combination with state proofs to make arbitrary assertions about a particular L1 state at a given block on the L2. 