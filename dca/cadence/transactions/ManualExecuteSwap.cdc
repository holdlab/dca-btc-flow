import "DCAContract"
import "DCATransactionHandler"
import "FungibleToken"
import "MockBTC"
import "SimpleSwap"

/// Manually execute a swap for testing (simulates what the scheduled transaction would do)
/// @param planId: The ID of the plan to execute
transaction(planId: UInt64) {

    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Borrow the plan manager
        let planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found")

        // Get the plan with execute permission
        let plan = planManager.borrowPlanWithExecute(planId: planId)
            ?? panic("Plan not found")

        // Check if plan can execute
        if !plan.canExecute() {
            panic("Plan cannot execute at this time")
        }

        // Execute the swap manually (this simulates what the Handler would do)
        // Withdraw USD from the plan
        let usdVault <- plan.withdrawForSwap()
        let amountIn = usdVault.balance

        // Swap USD for BTC
        let btcVaultFromSwap <- SimpleSwap.swapUSDForBTC(
            usdVault: <-usdVault,
            recipient: signer.address
        )
        let amountOut = btcVaultFromSwap.balance

        // Deposit BTC to user's account
        let btcVaultRef = signer.storage.borrow<&MockBTC.Vault>(from: MockBTC.VaultStoragePath)
            ?? panic("MockBTC vault not found. Run SetupMockTokens.cdc first")

        btcVaultRef.deposit(from: <-btcVaultFromSwap)

        // Record execution
        plan.recordExecution(amountOut: amountOut)

        log("Swap executed: ".concat(amountIn.toString()).concat(" USD -> ").concat(amountOut.toString()).concat(" BTC"))
    }

    execute {
        log("Manual swap execution complete")
    }
}

