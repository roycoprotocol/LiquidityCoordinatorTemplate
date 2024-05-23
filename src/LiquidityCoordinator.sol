// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract LiquidityCoordinator {
    address public poolToken;
    address public immutable POOLMANAGER;

    /// @notice the liquidity tokens that the coordinator is responsible for intaking
    /// @dev if the coordinator takes only 1 token as input, the array should have a length of 1
    address[] public tokens = [address(0)];

    modifier onlyPoolToken() {
        require(msg.sender == poolToken, "Only callable by PoolToken");
        _;
    }

    modifier onlyPoolManager() {
        require(msg.sender == POOLMANAGER, "Only callable by PoolManager");
        _;
    }

    constructor(address _poolManager) {
        POOLMANAGER = _poolManager;
    }

    /// @notice returns the total amount of liquidity that is controlled/redeemable by the coordinator
    /// @dev amounts[0] should correspond with the amount of tokens[0] and so on
    function totalLiquidityControlled() public view returns (uint256[] memory amounts) {
        amounts = new uint256[](0);
    }

    /// @notice called when a PoolToken is minted after the tokens are transferred to the coordinator
    /// @dev amounts[0] will correspond with the amount of tokens[0] and so on
    /// @param amounts the amounts of each token transferred to this contract before calling this function
    function afterReceive(uint256[] memory amounts) external onlyPoolToken {}

    /// @notice called when a PoolToken is burned before the tokens are transferred to the coordinator
    /// @dev the PoolToken will attempt to transfer the tokens from this contract to the redeemer immediately after this function is called
    function beforeReturn(uint256[] memory amounts) external onlyPoolToken {}

    /// @notice called by the PoolManager when the PoolToken is created to "connect" the PoolToken and the Coordinator
    /// @dev for most coordinators, this function can be left as is
    function onInitialize(address _poolToken) external onlyPoolManager {
        poolToken = _poolToken;
    }
}
