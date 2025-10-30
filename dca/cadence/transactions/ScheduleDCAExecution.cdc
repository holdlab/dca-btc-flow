import "DCAContract"
import "DCATransactionHandler"
import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "FlowToken"
import "FungibleToken"

/// Schedule automatic execution for a DCA plan using Flow's native scheduled transactions
/// The user must have already run SetupDCAHandler.cdc to create the Handler and Manager
/// 
/// Parameters:
/// - planId: The ID of the DCA plan to execute
/// - delaySeconds: How many seconds from now to schedule the first execution
/// - priority: Priority level (0=High, 1=Medium, 2=Low)
/// - executionEffort: Gas limit for the execution (e.g., 1000)
transaction(
    planId: UInt64,
    delaySeconds: UFix64,
    priority: UInt8,
    executionEffort: UInt64
) {
    prepare(signer: auth(Storage, Capabilities, BorrowValue) &Account) {
        
        // Verify the plan exists and is active
        let planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("Could not borrow PlanManager")
        
        let plan = planManager.borrowPlan(planId: planId)
            ?? panic("Plan not found")
        
        if !plan.isActive {
            panic("Plan is not active")
        }
        
        // Calculate execution timestamp
        let future = getCurrentBlock().timestamp + delaySeconds
        
        // Convert priority
        let pr = FlowTransactionScheduler.Priority(rawValue: priority)
            ?? FlowTransactionScheduler.Priority.Medium
        
        // Create execution data
        let executionData = DCATransactionHandler.ExecutionData(
            planOwner: signer.address,
            planId: planId,
            slippageTolerance: 0.05 // 5% slippage tolerance
        )
        
        // Estimate fees
        let estimate = FlowTransactionScheduler.estimate(
            data: executionData,
            timestamp: future,
            priority: pr,
            executionEffort: executionEffort
        )
        
        if estimate.timestamp == nil && pr != FlowTransactionScheduler.Priority.Low {
            panic("Failed to estimate fees: ".concat(estimate.error ?? "unknown error"))
        }
        
        // Verify handler exists
        if !signer.storage.check<@DCATransactionHandler.Handler>(
            from: DCATransactionHandler.HandlerStoragePath
        ) {
            panic("Handler not found. Run SetupDCAHandler.cdc first.")
        }

        // Get the entitled handler capability from storage controllers
        // This follows the pattern from the official Flow documentation
        var handlerCap: Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>? = nil

        let controllers = signer.capabilities.storage
            .getControllers(forPath: DCATransactionHandler.HandlerStoragePath)

        log("Found ".concat(controllers.length.toString()).concat(" controllers"))

        // Check controllers to find the entitled capability
        // The order is not guaranteed, so we check all of them
        for controller in controllers {
            log("Checking controller...")
            if let cap = controller.capability as? Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}> {
                log("Found entitled capability!")
                handlerCap = cap
                break
            }
        }

        if handlerCap == nil {
            panic("Could not find entitled handler capability. Found ".concat(controllers.length.toString()).concat(" controllers but none were entitled."))
        }
        
        // Withdraw fees from user's FlowToken vault
        let vaultRef = signer.storage
            .borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow FlowToken vault")
        
        let fees <- vaultRef.withdraw(amount: estimate.flowFee ?? 0.0) as! @FlowToken.Vault
        
        // Borrow user's Manager with Owner entitlement
        let manager = signer.storage
            .borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(
                from: FlowTransactionSchedulerUtils.managerStoragePath
            )
            ?? panic("Could not borrow Manager. Run SetupDCAHandler.cdc first.")
        
        // Schedule the execution
        manager.schedule(
            handlerCap: handlerCap!,
            data: executionData,
            timestamp: future,
            priority: pr,
            executionEffort: executionEffort,
            fees: <-fees
        )
        
        log("Scheduled DCA execution for plan ".concat(planId.toString())
            .concat(" at timestamp ").concat(future.toString()))
    }
    
    execute {
        log("DCA execution scheduled successfully!")
    }
}

