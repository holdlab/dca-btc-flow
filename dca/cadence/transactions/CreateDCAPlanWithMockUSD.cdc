import "DCAContract"
import "FungibleToken"
import "MockUSD"

/// Create a new DCA plan with MockUSD
/// @param amountPerExecution: Amount of USD to swap per execution
/// @param timeCycle: Time between executions in seconds
/// @param initialDepositAmount: Initial USD deposit amount
transaction(amountPerExecution: UFix64, timeCycle: UFix64, initialDepositAmount: UFix64) {
    
    let planManager: &DCAContract.PlanManager
    
    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Borrow the plan manager
        self.planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found. Run SetupAccount.cdc first")
        
        // Borrow the MockUSD vault
        let usdVault = signer.storage.borrow<auth(FungibleToken.Withdraw) &MockUSD.Vault>(
            from: MockUSD.VaultStoragePath
        ) ?? panic("Could not borrow MockUSD vault. Run SetupMockTokens.cdc first")
        
        // Withdraw USD for initial deposit
        let paymentVault <- usdVault.withdraw(amount: initialDepositAmount)
        
        // Create the DCA plan
        let planId = self.planManager.createPlan(
            amountPerExecution: amountPerExecution,
            timeCycle: timeCycle,
            initialDeposit: <-paymentVault
        )
        
        log("Created DCA plan with ID: ".concat(planId.toString()))
    }
    
    execute {
        log("DCA plan created successfully")
    }
}

