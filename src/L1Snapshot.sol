// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IL1Block} from "./interface/IL1Block.sol";
import {L1BlockSnapshot} from "./lib/Structs.sol";

contract L1Snapshot {
    ///@dev The L1 block contract to use for snapshots for all OP Stack chains.
    IL1Block public constant L1_BLOCK = IL1Block(0x4200000000000000000000000000000000000015);

    ///@dev Mapping of L1 block number to L1 block snapshot.
    mapping(uint256 l1BlockNumber => L1BlockSnapshot snapshot) snapshots;

    ///@dev Error thrown when no snapshot exists for a given L1 block number.
    error NoSnapshotForBlock(uint256 l1BlockNumber);

    /**
     * @notice Fallback function to snapshot the current L1 block without calldata overhead.
     */
    fallback() external {
        _snapshot();
    }

    /**
     * @notice Snapshot the current L1 block.
     */
    function snapshot() external {
        _snapshot();
    }

    /**
     * @notice Get the entire snapshot for a given L1 block number.
     * @param l1BlockNumber The L1 block number to get a snapshot for.
     */
    function getL1BlockSnapshot(uint256 l1BlockNumber) external view returns (L1BlockSnapshot memory) {
        return _getL1BlockSnapshot(l1BlockNumber);
    }

    /**
     * @notice Get the L1 block timestamp of a given L1 block number.
     * @param l1BlockNumber The L1 block number to get a snapshot for.
     */
    function getL1BlockTimestamp(uint256 l1BlockNumber) external view returns (uint256) {
        return _getL1BlockSnapshot(l1BlockNumber).timestamp;
    }

    function getL1BlockBasefee(uint256 l1BlockNumber) external view returns (uint256) {
        return _getL1BlockSnapshot(l1BlockNumber).basefee;
    }

    function getL1BlockHash(uint256 l1BlockNumber) external view returns (bytes32) {
        return _getL1BlockSnapshot(l1BlockNumber).hash;
    }

    function getL1BlockSequenceNumber(uint256 l1BlockNumber) external view returns (uint256) {
        return _getL1BlockSnapshot(l1BlockNumber).sequenceNumber;
    }

    function getL1BlockBatcherHash(uint256 l1BlockNumber) external view returns (bytes32) {
        return _getL1BlockSnapshot(l1BlockNumber).batcherHash;
    }

    function getL1BlockFeeOverhead(uint256 l1BlockNumber) external view returns (uint256) {
        return _getL1BlockSnapshot(l1BlockNumber).l1FeeOverhead;
    }

    function getL1BlockFeeScalar(uint256 l1BlockNumber) external view returns (uint256) {
        return _getL1BlockSnapshot(l1BlockNumber).l1FeeScalar;
    }

    /**
     * @dev Get the entire snapshot for a given L1 block number and check that it exists.
     * @param l1BlockNumber The L1 block number to get a snapshot for.
     * @return The L1 block snapshot as a storage pointer to avoid unnecessary SLOADs when accessing individual fields.
     */
    function _getL1BlockSnapshot(uint256 l1BlockNumber) internal view returns (L1BlockSnapshot storage) {
        L1BlockSnapshot storage existing = snapshots[l1BlockNumber];
        if (existing.number == 0) {
            revert NoSnapshotForBlock(l1BlockNumber);
        }
        return existing;
    }

    function _snapshot() internal {
        uint64 l1BlockNumber = L1_BLOCK.number();
        L1BlockSnapshot storage existing = snapshots[l1BlockNumber];
        // if snapshot already exists, do nothing
        if (existing.number != 0) {
            return;
        }
        // otherwise, create a new snapshot
        snapshots[l1BlockNumber] = L1BlockSnapshot({
            number: l1BlockNumber,
            timestamp: L1_BLOCK.timestamp(),
            basefee: L1_BLOCK.basefee(),
            hash: L1_BLOCK.hash(),
            sequenceNumber: L1_BLOCK.sequenceNumber(),
            batcherHash: L1_BLOCK.batcherHash(),
            l1FeeOverhead: L1_BLOCK.l1FeeOverhead(),
            l1FeeScalar: L1_BLOCK.l1FeeScalar()
        });
    }
}
