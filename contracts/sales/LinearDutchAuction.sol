// SPDX-License-Identifier: MIT
// Copyright (c) 2021 Divergent Technologies Ltd (github.com/divergencetech)
pragma solidity >=0.8.0 <0.9.0;

import "./PurchaseManager.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/// @notice A PurchaseManager with a linearly decreasing price.
abstract contract LinearDutchAuction is PurchaseManager {
    /**
    @param startBlock The first block in which purchases are allowed.
    @param endBlock Last block for which cost(n) < cost(n) in the previous
    block.
    @param startPrice Price of a single item when block.number==startBlock.
    @param perBlockDecrease Amount by which to decrease, per block, from
    startPrice.
     */
    struct DutchAuctionConfig {
        uint256 startBlock;
        uint256 endBlock;
        uint256 startPrice;
        uint256 perBlockDecrease;
    }

    constructor(
        DutchAuctionConfig memory config,
        PurchaseManager.PurchaseConfig memory purchaseConfig,
        address payable _beneficiary
    ) PurchaseManager(purchaseConfig, _beneficiary) {
        setAuctionConfig(config);
    }

    /// @notice Configuration of price changes.
    DutchAuctionConfig public dutchAuctionConfig;

    /// @notice Sets the purchase config.
    function setAuctionConfig(DutchAuctionConfig memory config)
        public
        onlyOwner
    {
        dutchAuctionConfig = config;
    }

    /// @notice Override of PurchaseManager.cost() with Dutch-auction logic.
    function cost(uint256 n) public view override returns (uint256) {
        DutchAuctionConfig storage cfg = dutchAuctionConfig;
        require(
            block.number >= cfg.startBlock,
            "LinearDutchAuction: Not started"
        );

        uint256 blocks = Math.min(block.number, cfg.endBlock) - cfg.startBlock;
        return n * (cfg.startPrice - blocks * cfg.perBlockDecrease);
    }
}