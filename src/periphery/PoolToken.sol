// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "../../lib/solmate/src/utils/SafeTransferLib.sol";
import {ILiquidityCoordinator} from "../interfaces/ILiquidityCoordinator.sol";
import {FixedPointMathLib} from "../../lib/solmate/src/utils/FixedPointMathLib.sol";

contract PoolToken is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    ILiquidityCoordinator public immutable COORDINATOR;
    address public immutable POOLMANAGER;

    mapping(address => bool) public isApprovedMinter;
    uint256[] public initialAssetsPerPoolToken;
    uint256 public timelockExpiry;

    modifier onlyMinter() {
        require(isApprovedMinter[msg.sender], "Only minter can call this function");
        _;
    }

    modifier onlyPoolManager() {
        require(msg.sender == POOLMANAGER, "Only PoolManager can call this function");
        _;
    }

    constructor(
        address _poolManager,
        address _liquidityCoordinator,
        string memory _name,
        string memory _symbol,
        uint256 _timelockExpiry,
        uint256[] memory _initialAssetsPerPoolToken
    ) ERC20(_name, _symbol, 18) {
        COORDINATOR = ILiquidityCoordinator(_liquidityCoordinator);
        POOLMANAGER = _poolManager;
        initialAssetsPerPoolToken = _initialAssetsPerPoolToken;
        timelockExpiry = _timelockExpiry;
    }

    function addMinter(address minter) external onlyPoolManager {
        require(!isApprovedMinter[minter], "Already a minter");
        isApprovedMinter[minter] = true;
    }

    function removeMinter(address minter) external onlyPoolManager {
        require(isApprovedMinter[minter], "Not a minter");
        isApprovedMinter[minter] = false;
    }

    function mint(address to, uint256 quantity) external onlyMinter {
        address[] memory assets;
        uint256[] memory amounts;
        (assets, amounts) = convertToAssets(quantity);

        _mint(to, quantity);

        uint256 n = assets.length;
        for (uint256 i = 0; i < n;) {
            ERC20 asset = ERC20(assets[i]);
            asset.safeTransferFrom(msg.sender, address(COORDINATOR), amounts[i]);
            ++i;
        }
        COORDINATOR.afterReceive(amounts);
    }

    /// @notice Helper function to check if an amount of tokens is mintable given the minter's approvals and balances
    function canMint(address minter, uint256 quantity) external view returns (bool) {
        address[] memory assets;
        uint256[] memory amounts;
        (assets, amounts) = convertToAssets(quantity);

        uint256 n = assets.length;
        for (uint256 i = 0; i < n;) {
            ERC20 asset = ERC20(assets[i]);
            uint256 amount = amounts[i];
            if (asset.balanceOf(minter) < amount || asset.allowance(minter, address(this)) < amount) {
                return false;
            }
            ++i;
        }
        return true;
    }

    function burn(uint256 quantity) external {
        require(block.timestamp >= timelockExpiry, "Timelock not expired");
        address[] memory assets;
        uint256[] memory amounts;
        (assets, amounts) = convertToAssets(quantity);

        _burn(msg.sender, quantity);

        COORDINATOR.beforeReturn(amounts);

        uint256 n = assets.length;
        for (uint256 i = 0; i < n;) {
            ERC20 asset = ERC20(assets[i]);
            asset.safeTransfer(msg.sender, amounts[i]);
            ++i;
        }
    }

    function convertToAssets(uint256 shares) public view returns (address[] memory assets, uint256[] memory amounts) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        assets = COORDINATOR.tokens();
        uint256[] memory totals = COORDINATOR.totalLiquidityControlled();

        uint256 n = assets.length;
        for (uint256 i = 0; i < n;) {
            amounts[i] = supply == 0 ? shares * initialAssetsPerPoolToken[i] : shares.mulDivDown(totals[i], supply);
            ++i;
        }
    }
}
