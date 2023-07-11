// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct L1BlockSnapshot {
    uint64 number;
    uint64 timestamp;
    uint64 sequenceNumber;
    uint256 basefee;
    bytes32 hash;
    bytes32 batcherHash;
    uint256 l1FeeOverhead;
    uint256 l1FeeScalar;
}
