// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {PoolToken} from "./PoolToken.sol";
import {Ownable2Step, Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract PoolManager is Ownable2Step {
    address public defaultMinter;
    address[] public poolTokens;

    event PoolCreated(address poolToken);
    event PoolAdded(address poolToken);
    event MinterAdded(address poolToken, address minter);
    event MinterRemoved(address poolToken, address minter);
    event DefaultMinterSet(address minter);

    constructor(address _defaultMinter) Ownable(msg.sender) {
        defaultMinter = _defaultMinter;
    }

    /// @notice Permissionless route for deploying a PoolToken, allowing custom liquidity coordinators but restricting
    ///         the PoolToken to the default implementation
    function createPool(
        address _liquidityCoordinator,
        string memory _name,
        uint256 _timelockExpiry,
        uint256[] memory _initialAssetsPerPoolToken
    ) external {
        string memory symbol = "ROYCO-POOLTOKEN"; //TODO: cooler symbol
        PoolToken poolToken = new PoolToken(
            address(this),
            _liquidityCoordinator,
            _name,
            symbol,
            _timelockExpiry,
            _initialAssetsPerPoolToken
        );
        poolToken.addMinter(defaultMinter);
        poolTokens.push(address(poolToken));
        emit PoolCreated(address(poolToken));
    }

    /// @notice permissioned function for adding nonstandard PoolTokens
    function addPool(address poolToken) external onlyOwner {
        poolTokens.push(poolToken);
        emit PoolAdded(poolToken);
    }

    function addMinter(address poolToken, address minter) external onlyOwner {
        PoolToken(poolToken).addMinter(minter);
        emit MinterAdded(poolToken, minter);
    }

    function removeMinter(address poolToken, address minter) external onlyOwner {
        PoolToken(poolToken).removeMinter(minter);
        emit MinterRemoved(poolToken, minter);
    }

    function setDefaultMinter(address minter) external onlyOwner {
        defaultMinter = minter;
        emit DefaultMinterSet(minter);
    }
}
