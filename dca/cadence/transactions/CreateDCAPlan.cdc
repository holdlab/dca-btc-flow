import "DCAContract"
import "FungibleToken"
import "FlowToken"

/// CreateDCAPlan - Create a new DCA plan
/// 
/// Parameters:
/// - amountPerExecution: Amount of USD to swap per execution (e.g., 100.0)
/// - timeCycle: Time between executions in seconds (e.g., 86400.0 for 24 hours)
/// - initialDepositAmount: Initial USD deposit amount
transaction(
    amountPerExecution: UFix64,
    timeCycle: UFix64,
    initialDepositAmount: UFix64
) {
    let planManager: &DCAContract.PlanManager
    let paymentVault: @{FungibleToken.Vault}

    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Borrow PlanManager
        self.planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found. Run SetupAccount.cdc first")

        // Get FlowToken vault for initial deposit
        // In production, this would be a USD stablecoin vault
        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FlowToken vault")

        // Withdraw initial deposit
        self.paymentVault <- vaultRef.withdraw(amount: initialDepositAmount)
    }

    execute {
        // Create the DCA plan
        let planId = self.planManager.createPlan(
            amountPerExecution: amountPerExecution,
            timeCycle: timeCycle,
            initialDeposit: <-self.paymentVault
        )

        log("DCA Plan created with ID: ".concat(planId.toString()))
        log("Amount per execution: ".concat(amountPerExecution.toString()))
        log("Time cycle: ".concat(timeCycle.toString()).concat(" seconds"))
        log("Initial deposit: ".concat(initialDepositAmount.toString()))
    }
}

