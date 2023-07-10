// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IL1Block} from "./interface/IL1Block.sol";
import {L1BlockSnapshot} from "./lib/Structs.sol";
import {
    NUMBER_SELECTOR,
    TIMESTAMP_SELECTOR,
    BASEFEE_SELECTOR,
    HASH_SELECTOR,
    SEQUENCE_NUMBER_SELECTOR,
    BATCHER_HASH_SELECTOR,
    L1_FEE_OVERHEAD_SELECTOR,
    L1_FEE_SCALAR_SELECTOR
} from "./lib/Constants.sol";

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
        uint64 l1BlockNumber = uint64(_callL1Block(NUMBER_SELECTOR));
        L1BlockSnapshot storage existing = snapshots[l1BlockNumber];
        // if snapshot already exists, do nothing
        if (existing.number != 0) {
            return;
        }
        // otherwise, create a new snapshot
        snapshots[l1BlockNumber] = L1BlockSnapshot({
            number: l1BlockNumber,
            timestamp: uint64(_callL1Block(TIMESTAMP_SELECTOR)),
            basefee: _callL1Block(BASEFEE_SELECTOR),
            hash: bytes32(_callL1Block(HASH_SELECTOR)),
            sequenceNumber: uint64(_callL1Block(SEQUENCE_NUMBER_SELECTOR)),
            batcherHash: bytes32(_callL1Block(BATCHER_HASH_SELECTOR)),
            l1FeeOverhead: _callL1Block(L1_FEE_OVERHEAD_SELECTOR),
            l1FeeScalar: _callL1Block(L1_FEE_SCALAR_SELECTOR)
        });
    }

    /**
     * @dev Call the L1 block contract with a given selector and return the first word of returndata.
     *
     */
    function _callL1Block(uint256 selectorConst) internal view returns (uint256 val) {
        address l1BlockAddress = address(L1_BLOCK);
        assembly {
            mstore(0, selectorConst)
            if iszero(
                staticcall(
                    // forward all gass
                    gas(),
                    // call address
                    l1BlockAddress,
                    // read from 0x1c
                    0x1c,
                    // read 4 bytes
                    0x04,
                    // write returndata starting at 0x0
                    0,
                    // write 32 bytes of returndata
                    0x20
                )
            ) {
                // on failure, copy all returndata to memory
                returndatacopy(0, 0, returndatasize())
                // revert with returndata
                revert(0, returndatasize())
            }
            // on success, read the first word of memory onto the stack and return it
            val := mload(0)
        }
    }
}
