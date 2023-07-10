// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @notice modified from https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/L2/L1Block.sol
/// @custom:predeploy 0x4200000000000000000000000000000000000015
/// @title IL1Block
/// @notice The L1Block predeploy gives users access to information about the last known L1 block.
///         Values within this contract are updated once per epoch (every L1 block) and can only be
///         set by the "depositor" account, a special system address. Depositor account transactions
///         are created by the protocol whenever we move to a new epoch.
interface IL1Block {
    /// @notice The address that is allowed to update the L1 block values.
    function DEPOSITOR_ACCOUNT() external view returns (address);
    /// @notice The latest L1 block number known by the L2 system.
    function number() external view returns (uint64);
    /// @notice The latest L1 timestamp known by the L2 system.
    function timestamp() external view returns (uint64);
    /// @notice The latest L1 basefee.
    function basefee() external view returns (uint256);
    /// @notice The latest L1 blockhash.
    function hash() external view returns (bytes32);
    /// @notice The number of L2 blocks in the same epoch.
    function sequenceNumber() external view returns (uint64);
    /// @notice The versioned hash to authenticate the batcher by.
    function batcherHash() external view returns (bytes32);
    /// @notice The overhead value applied to the L1 portion of the transaction fee.
    function l1FeeOverhead() external view returns (uint256);
    /// @notice The scalar value applied to the L1 portion of the transaction fee.
    function l1FeeScalar() external view returns (uint256);

    /// @notice Updates the L1 block values.
    /// @param _number         L1 blocknumber.
    /// @param _timestamp      L1 timestamp.
    /// @param _basefee        L1 basefee.
    /// @param _hash           L1 blockhash.
    /// @param _sequenceNumber Number of L2 blocks since epoch start.
    /// @param _batcherHash    Versioned hash to authenticate batcher by.
    /// @param _l1FeeOverhead  L1 fee overhead.
    /// @param _l1FeeScalar    L1 fee scalar.
    function setL1BlockValues(
        uint64 _number,
        uint64 _timestamp,
        uint256 _basefee,
        bytes32 _hash,
        uint64 _sequenceNumber,
        bytes32 _batcherHash,
        uint256 _l1FeeOverhead,
        uint256 _l1FeeScalar
    ) external;
}
