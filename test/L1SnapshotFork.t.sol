// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {L1Snapshot, L1BlockSnapshot, IL1Block} from "../src/L1Snapshot.sol";

contract L1SnapshotForkTest is Test {
    L1Snapshot snapshot;
    IL1Block l1Block;

    function setUp() public {
        snapshot = new L1Snapshot();
        l1Block = snapshot.L1_BLOCK();
    }

    function testSnapshot_fork() public {
        string[] memory networks = new string[](4);
        networks[0] = "optimism";
        networks[1] = "base_goerli";
        networks[2] = "zora";
        networks[3] = "zora_testnet";
        for (uint256 i = 0; i < networks.length; i++) {
            vm.createSelectFork(vm.rpcUrl(networks[i]));
            _runFork();
        }
    }

    function _runFork() internal {
        snapshot = new L1Snapshot();
        snapshot.snapshot();
        L1BlockSnapshot memory l1BlockSnapshot = snapshot.getL1BlockSnapshot(l1Block.number());
        assertEq(l1BlockSnapshot.number, l1Block.number());
        assertEq(l1BlockSnapshot.timestamp, l1Block.timestamp());
        assertEq(l1BlockSnapshot.basefee, l1Block.basefee());
        assertEq(l1BlockSnapshot.hash, l1Block.hash());
        assertEq(l1BlockSnapshot.sequenceNumber, l1Block.sequenceNumber());
        assertEq(l1BlockSnapshot.batcherHash, l1Block.batcherHash());
        assertEq(l1BlockSnapshot.l1FeeOverhead, l1Block.l1FeeOverhead());
        assertEq(l1BlockSnapshot.l1FeeScalar, l1Block.l1FeeScalar());
    }
}
