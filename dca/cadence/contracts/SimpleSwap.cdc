import "FungibleToken"
import "MockUSD"
import "MockBTC"

/// SimpleSwap - A simple DEX for testing
/// Fixed exchange rate: 1 BTC = 50,000 USD
access(all) contract SimpleSwap {

    access(all) var exchangeRate: UFix64  // USD per BTC
    access(all) var totalSwaps: UInt64

    access(all) event SwapExecuted(
        amountIn: UFix64,
        amountOut: UFix64,
        from: Address?,
        to: Address?
    )
    access(all) event ExchangeRateUpdated(newRate: UFix64)

    /// Swap USD for BTC
    /// @param usdVault: Vault containing USD to swap
    /// @param recipient: Address to receive BTC
    /// @return BTC vault
    access(all) fun swapUSDForBTC(
        usdVault: @{FungibleToken.Vault},
        recipient: Address
    ): @{FungibleToken.Vault} {
        pre {
            usdVault.balance > 0.0: "USD amount must be greater than 0"
        }

        let usdAmount = usdVault.balance

        // Calculate BTC amount: BTC = USD / exchangeRate
        let btcAmount = usdAmount / self.exchangeRate

        // Destroy the USD vault (in production, this would go to liquidity pool)
        destroy usdVault

        // Mint BTC (in production, this would come from liquidity pool)
        let btcVault <- MockBTC.mintTokens(amount: btcAmount)

        self.totalSwaps = self.totalSwaps + 1

        emit SwapExecuted(
            amountIn: usdAmount,
            amountOut: btcAmount,
            from: nil,
            to: recipient
        )

        return <- btcVault
    }

    /// Swap BTC for USD
    /// @param btcVault: Vault containing BTC to swap
    /// @param recipient: Address to receive USD
    /// @return USD vault
    access(all) fun swapBTCForUSD(
        btcVault: @{FungibleToken.Vault},
        recipient: Address
    ): @{FungibleToken.Vault} {
        pre {
            btcVault.balance > 0.0: "BTC amount must be greater than 0"
        }

        let btcAmount = btcVault.balance

        // Calculate USD amount: USD = BTC * exchangeRate
        let usdAmount = btcAmount * self.exchangeRate

        // Destroy the BTC vault (in production, this would go to liquidity pool)
        destroy btcVault

        // Mint USD (in production, this would come from liquidity pool)
        let usdVault <- MockUSD.mintTokens(amount: usdAmount)

        self.totalSwaps = self.totalSwaps + 1

        emit SwapExecuted(
            amountIn: btcAmount,
            amountOut: usdAmount,
            from: nil,
            to: recipient
        )

        return <- usdVault
    }

    /// Get quote for USD to BTC swap
    /// @param usdAmount: Amount of USD to swap
    /// @return Expected BTC amount
    access(all) view fun getQuoteUSDForBTC(usdAmount: UFix64): UFix64 {
        return usdAmount / self.exchangeRate
    }

    /// Get quote for BTC to USD swap
    /// @param btcAmount: Amount of BTC to swap
    /// @return Expected USD amount
    access(all) view fun getQuoteBTCForUSD(btcAmount: UFix64): UFix64 {
        return btcAmount * self.exchangeRate
    }

    /// Update exchange rate (admin only)
    access(account) fun updateExchangeRate(newRate: UFix64) {
        self.exchangeRate = newRate
        emit ExchangeRateUpdated(newRate: newRate)
    }

    init() {
        self.exchangeRate = 50000.0  // 1 BTC = 50,000 USD
        self.totalSwaps = 0
    }
}

