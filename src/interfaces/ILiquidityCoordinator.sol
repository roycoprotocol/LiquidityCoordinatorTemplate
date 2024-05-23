// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ILiquidityCoordinator {
    function tokens() external view returns (address[] memory tokens);
    function totalLiquidityControlled() external view returns (uint256[] memory amounts);
    function afterReceive(uint256[] memory amounts) external;
    function beforeReturn(uint256[] memory amounts) external;
    function onInitialize(address _poolToken) external;
    function claimRewards() external;
}
