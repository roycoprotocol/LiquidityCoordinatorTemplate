### Royco Liquidity Coordinator Template Repository

Full documentation of the Royco Protocol, and how to deploy a Liquidity Coordinator can be found in the [technical documentation](https://waymont.notion.site/Royco-Technical-Docs-bacd16fed2f849b1a6d2fd7d8ad6994d)

#### Quickstart:
1. In `./src/LiquidityCoordinator.sol`, set the `tokens` array to the ERC20 addresses of the assets which the Liquidity Coordinator should intake
2. Fill out the `totalLiquidityControlled()`, `afterReceive()` and `beforeReturn()` functions to interface with an external protocol that needs liquidity
3. If a "Rewards Token" from a traditional liquidity mining program should be distributed, specify `rewardsAsset` and implement `claimRewards()`
4. Deploy the new Liquidity Coordinator contract
5. Connect the Liquidity Coordinator to a new PoolToken via the `createPool()` function in the PoolManager contract (souce code for PoolManager can be found in `./src/periphery/PoolManager.sol` and a sample PoolManager deployment can be found on Sepolia testnet at [0xe2f7b12688d1add6b09e0649a119ca051b484c94](https://sepolia.etherscan.io/address/0xe2f7b12688d1add6b09e0649a119ca051b484c94)
