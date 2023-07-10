// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {L1Snapshot, L1BlockSnapshot, IL1Block} from "../src/L1Snapshot.sol";
import {L1BlockMock} from "./L1Snapshot.t.sol";

contract L1SnapshotGasTest is Test {
    L1Snapshot test;
    IL1Block mock;

    function setUp() public {
        vm.pauseGasMetering();
        test = new L1Snapshot();
        mock = new L1BlockMock();
        vm.etch(address(test.L1_BLOCK()), address(mock).code);
        mock = test.L1_BLOCK();
        mock.setL1BlockValues(1, 2, 3, bytes32(uint256(4)), 5, bytes32(uint256(6)), 7, 8);
    }

    modifier metered() {
        vm.resumeGasMetering();
        _;
        // vm.pauseGasMetering();
    }

    modifier snapshotMetered() {
        test.snapshot();
        vm.resumeGasMetering();
        _;
        // vm.pauseGasMetering();
    }

    function _runSnapshot(L1Snapshot snapshot) internal metered {
        snapshot.snapshot();
    }

    function _runSnapshotFallback(L1Snapshot snapshot) internal metered returns (bool succ) {
        (succ,) = address(snapshot).call("");
    }

    function _runTimestamp(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockTimestamp(1);
    }

    function _runBasefee(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockBasefee(1);
    }

    function _runHash(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockHash(1);
    }

    function _runSequenceNumber(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockSequenceNumber(1);
    }

    function _runBatcherHash(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockBatcherHash(1);
    }

    function _runL1FeeOverhead(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockFeeOverhead(1);
    }

    function _runL1FeeScalar(L1Snapshot snapshot) internal snapshotMetered {
        snapshot.getL1BlockFeeScalar(1);
    }

    function testSnapshot_gasSnapshot() public {
        _runSnapshot(test);
    }

    function testSnapshotFallback_gasSnapshot() public {
        _runSnapshotFallback(test);
    }

    function testTimestamp_gasSnapshot() public {
        _runTimestamp(test);
    }

    function testBasefee_gasSnapshot() public {
        _runBasefee(test);
    }

    function testHash_gasSnapshot() public {
        _runHash(test);
    }

    function testSequenceNumber_gasSnapshot() public {
        _runSequenceNumber(test);
    }

    function testBatcherHash_gasSnapshot() public {
        _runBatcherHash(test);
    }

    function testL1FeeOverhead_gasSnapshot() public {
        _runL1FeeOverhead(test);
    }

    function testL1FeeScalar_gasSnapshot() public {
        _runL1FeeScalar(test);
    }
}
