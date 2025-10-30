import "FungibleToken"
import "MockUSD"
import "MockBTC"

/// Setup MockUSD and MockBTC vaults for the user
/// This transaction creates vaults for both tokens and mints initial amounts for testing
transaction(initialUSD: UFix64, initialBTC: UFix64) {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Setup MockUSD vault
        if signer.storage.borrow<&MockUSD.Vault>(from: MockUSD.VaultStoragePath) == nil {
            let usdVault <- MockUSD.createEmptyVault(vaultType: Type<@MockUSD.Vault>())
            signer.storage.save(<-usdVault, to: MockUSD.VaultStoragePath)
            
            let usdCap = signer.capabilities.storage.issue<&MockUSD.Vault>(MockUSD.VaultStoragePath)
            signer.capabilities.publish(usdCap, at: MockUSD.VaultPublicPath)
        }

        // Setup MockBTC vault
        if signer.storage.borrow<&MockBTC.Vault>(from: MockBTC.VaultStoragePath) == nil {
            let btcVault <- MockBTC.createEmptyVault(vaultType: Type<@MockBTC.Vault>())
            signer.storage.save(<-btcVault, to: MockBTC.VaultStoragePath)
            
            let btcCap = signer.capabilities.storage.issue<&MockBTC.Vault>(MockBTC.VaultStoragePath)
            signer.capabilities.publish(btcCap, at: MockBTC.VaultPublicPath)
        }

        // Mint initial USD
        if initialUSD > 0.0 {
            let mintedUSD <- MockUSD.mintTokens(amount: initialUSD)
            let usdVault = signer.storage.borrow<&MockUSD.Vault>(from: MockUSD.VaultStoragePath)!
            usdVault.deposit(from: <-mintedUSD)
        }

        // Mint initial BTC
        if initialBTC > 0.0 {
            let mintedBTC <- MockBTC.mintTokens(amount: initialBTC)
            let btcVault = signer.storage.borrow<&MockBTC.Vault>(from: MockBTC.VaultStoragePath)!
            btcVault.deposit(from: <-mintedBTC)
        }
    }

    execute {
        log("MockUSD and MockBTC vaults setup complete")
    }
}

