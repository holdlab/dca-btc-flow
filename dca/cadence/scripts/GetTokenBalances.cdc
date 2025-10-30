import "FungibleToken"
import "MockUSD"
import "MockBTC"

/// Get MockUSD and MockBTC balances for an address
/// @param address: The address to check
/// @return Dictionary with USD and BTC balances
access(all) fun main(address: Address): {String: UFix64} {
    let account = getAccount(address)
    var balances: {String: UFix64} = {}

    // Get MockUSD balance
    let usdCap = account.capabilities.get<&MockUSD.Vault>(MockUSD.VaultPublicPath)
    if let usdVault = usdCap.borrow() {
        balances["USD"] = usdVault.balance
    } else {
        balances["USD"] = 0.0
    }

    // Get MockBTC balance
    let btcCap = account.capabilities.get<&MockBTC.Vault>(MockBTC.VaultPublicPath)
    if let btcVault = btcCap.borrow() {
        balances["BTC"] = btcVault.balance
    } else {
        balances["BTC"] = 0.0
    }

    return balances
}

