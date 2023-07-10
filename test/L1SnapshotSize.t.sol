// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {L1Snapshot} from "../src/L1Snapshot.sol";
import {TestPlus} from "solady-test/utils/TestPlus.sol";

contract L1SnapshotSizeTest is Test, TestPlus {
    L1Snapshot l1Snapshot;

    function setUp() public {
        l1Snapshot = new L1Snapshot();
    }
}
