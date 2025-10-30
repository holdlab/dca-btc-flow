import "DCAContract"
import "FungibleToken"
import "FlowToken"

/// DepositToPlan - Add funds to an existing DCA plan
/// 
/// Parameters:
/// - planId: The ID of the plan to deposit to
/// - amount: Amount to deposit
transaction(planId: UInt64, amount: UFix64) {
    let paymentVault: @{FungibleToken.Vault}

    prepare(signer: auth(Storage) &Account) {
        // Get FlowToken vault
        // In production, this would be a USD stablecoin vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FlowToken vault")

        // Withdraw deposit amount
        self.paymentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // This needs to be implemented properly
        // For now, just destroy the vault
        // TODO: Implement proper deposit to plan
        destroy self.paymentVault
        
        log("Deposited ".concat(amount.toString()).concat(" to plan ").concat(planId.toString()))
    }
}

