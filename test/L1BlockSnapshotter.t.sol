// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {L1BlockSnapshotter, L1BlockSnapshot, IL1Block} from "../src/L1BlockSnapshotter.sol";

contract L1BlockMock is IL1Block {
    L1BlockSnapshot snapshot;

    function DEPOSITOR_ACCOUNT() external pure override returns (address) {}

    function number() external view override returns (uint64) {
        return snapshot.number;
    }

    function timestamp() external view override returns (uint64) {
        return snapshot.timestamp;
    }

    function basefee() external view override returns (uint256) {
        return snapshot.basefee;
    }

    function hash() external view override returns (bytes32) {
        return snapshot.hash;
    }

    function sequenceNumber() external view override returns (uint64) {
        return snapshot.sequenceNumber;
    }

    function batcherHash() external view override returns (bytes32) {
        return snapshot.batcherHash;
    }

    function l1FeeOverhead() external view override returns (uint256) {
        return snapshot.l1FeeOverhead;
    }

    function l1FeeScalar() external view override returns (uint256) {
        return snapshot.l1FeeScalar;
    }

    function setL1BlockValues(
        uint64 _number,
        uint64 _timestamp,
        uint256 _basefee,
        bytes32 _hash,
        uint64 _sequenceNumber,
        bytes32 _batcherHash,
        uint256 _l1FeeOverhead,
        uint256 _l1FeeScalar
    ) external {
        snapshot = L1BlockSnapshot({
            number: _number,
            timestamp: _timestamp,
            basefee: _basefee,
            hash: _hash,
            sequenceNumber: _sequenceNumber,
            batcherHash: _batcherHash,
            l1FeeOverhead: _l1FeeOverhead,
            l1FeeScalar: _l1FeeScalar
        });
    }
}

contract L1BlockSnapshotterTest is Test {
    L1BlockSnapshotter test;
    IL1Block mock;

    function setUp() public {
        test = new L1BlockSnapshotter();
        mock = new L1BlockMock();
        vm.etch(address(test.L1_BLOCK()), address(mock).code);
        mock = test.L1_BLOCK();
        mock.setL1BlockValues(1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);
    }

    function testSnapshot() public {
        test.snapshot();
        L1BlockSnapshot memory snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);

        // subsequent call should write nothing;

        vm.record();
        test.snapshot();
        (, bytes32[] memory writeSlots) = vm.accesses(address(test));
        assertEq(writeSlots.length, 0, "should not write anything");

        snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);

        // updated call should update correct block
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        snapshot = test.getL1BlockSnapshot(2);
        _assertSnapshot(snapshot, 2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);

        // old block should be unchanged
        snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);
    }

    function _assertSnapshot(
        L1BlockSnapshot memory snapshot,
        uint64 _number,
        uint64 _timestamp,
        uint256 _basefee,
        bytes32 _hash,
        uint64 _sequenceNumber,
        bytes32 _batcherHash,
        uint256 _l1FeeOverhead,
        uint256 _l1FeeScalar
    ) internal {
        assertEq(snapshot.number, _number);
        assertEq(snapshot.timestamp, _timestamp);
        assertEq(snapshot.basefee, _basefee);
        assertEq(snapshot.hash, _hash);
        assertEq(snapshot.sequenceNumber, _sequenceNumber);
        assertEq(snapshot.batcherHash, _batcherHash);
        assertEq(snapshot.l1FeeOverhead, _l1FeeOverhead);
        assertEq(snapshot.l1FeeScalar, _l1FeeScalar);
    }

    function testSnapshot_fallback() public {
        (bool succ,) = address(test).call("");
        assertTrue(succ);
        L1BlockSnapshot memory snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);

        vm.record();
        (succ,) = address(test).call("");
        assertTrue(succ);
        (, bytes32[] memory writeSlots) = vm.accesses(address(test));
        assertEq(writeSlots.length, 0, "should not write anything");
        snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);

        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        (succ,) = address(test).call("");
        assertTrue(succ);
        snapshot = test.getL1BlockSnapshot(2);
        _assertSnapshot(snapshot, 2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);

        snapshot = test.getL1BlockSnapshot(1);
        _assertSnapshot(snapshot, 1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);
    }

    function testSnapshot_NoSnapshotForBlock() public {
        vm.expectRevert(abi.encodeWithSelector(L1BlockSnapshotter.NoSnapshotForBlock.selector, uint256(2)));
        test.getL1BlockSnapshot(2);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
    }

    function testGetL1BlockTimestamp() public {
        test.snapshot();
        assertEq(test.getL1BlockTimestamp(1), 2);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockTimestamp(2), 3);
    }

    function testGetL1BlockBasefee() public {
        test.snapshot();
        assertEq(test.getL1BlockBasefee(1), 3);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockBasefee(2), 4);
    }

    function testGetL1BlockHash() public {
        test.snapshot();
        assertEq(test.getL1BlockHash(1), bytes32(uint256(4)));
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockHash(2), bytes32(uint256(5)));
    }

    function testGetL1BlockSequenceNumber() public {
        test.snapshot();
        assertEq(test.getL1BlockSequenceNumber(1), 5);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockSequenceNumber(2), 6);
    }

    function testGetL1BlockBatcherHash() public {
        test.snapshot();
        assertEq(test.getL1BlockBatcherHash(1), bytes32(uint256(6)));
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockBatcherHash(2), bytes32(uint256(7)));
    }

    function testGetL1FeeOverhead() public {
        test.snapshot();
        assertEq(test.getL1BlockFeeOverhead(1), 7);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockFeeOverhead(2), 8);
    }

    function testGetL1FeeScalar() public {
        test.snapshot();
        assertEq(test.getL1BlockFeeScalar(1), 8);
        mock.setL1BlockValues(2, 3, 4, bytes32(uint256(5)), 6, bytes32(uint256(7)), 8, 9);
        test.snapshot();
        assertEq(test.getL1BlockFeeScalar(2), 9);
    }
}
