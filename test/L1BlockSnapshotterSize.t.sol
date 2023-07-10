// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {L1BlockSnapshotter} from "../src/L1BlockSnapshotter.sol";
import {TestPlus} from "solady-test/utils/TestPlus.sol";

contract L1BlockSnapshotterSizeTest is Test, TestPlus {
    L1BlockSnapshotter l1BlockSnapshotter;

    function setUp() public {
        l1BlockSnapshotter = new L1BlockSnapshotter();
    }
}
