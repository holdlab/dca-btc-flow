import "DCAContract"
import "DCATransactionHandler"
import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "FlowToken"
import "FungibleToken"

/// Schedule multiple automatic executions for a DCA plan
/// This allows you to pre-schedule multiple executions at once
/// 
/// Parameters:
/// - planId: The ID of the DCA plan to execute
/// - numberOfExecutions: How many executions to schedule (e.g., 10 for 10 executions)
/// - intervalSeconds: Time between each execution (should match plan's timeCycle)
/// - priority: Priority level (0=High, 1=Medium, 2=Low)
/// - executionEffort: Gas limit for each execution (e.g., 1000)
transaction(
    planId: UInt64,
    numberOfExecutions: Int,
    intervalSeconds: UFix64,
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
        
        // Convert priority
        let pr = FlowTransactionScheduler.Priority(rawValue: priority)
            ?? FlowTransactionScheduler.Priority.Medium
        
        // Create execution data
        let executionData = DCATransactionHandler.ExecutionData(
            planOwner: signer.address,
            planId: planId,
            slippageTolerance: 0.05 // 5% slippage tolerance
        )
        
        // Verify handler exists
        if !signer.storage.check<@DCATransactionHandler.Handler>(
            from: DCATransactionHandler.HandlerStoragePath
        ) {
            panic("Handler not found. Run SetupDCAHandler.cdc first.")
        }

        // Get the entitled handler capability
        var handlerCap: Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>? = nil

        let controllers = signer.capabilities.storage
            .getControllers(forPath: DCATransactionHandler.HandlerStoragePath)

        for controller in controllers {
            if let cap = controller.capability as? Capability<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}> {
                handlerCap = cap
                break
            }
        }

        if handlerCap == nil {
            panic("Could not find entitled handler capability")
        }
        
        // Get FlowToken vault reference
        let vaultRef = signer.storage
            .borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow FlowToken vault")
        
        // Borrow Manager
        let manager = signer.storage
            .borrow<auth(FlowTransactionSchedulerUtils.Owner) &{FlowTransactionSchedulerUtils.Manager}>(
                from: FlowTransactionSchedulerUtils.managerStoragePath
            )
            ?? panic("Could not borrow Manager")
        
        // Schedule multiple executions
        var i = 0
        var totalFees = 0.0
        
        while i < numberOfExecutions {
            // Calculate execution timestamp for this iteration
            let delaySeconds = intervalSeconds * UFix64(i + 1)
            let executionTime = getCurrentBlock().timestamp + delaySeconds
            
            // Estimate fees for this execution
            let estimate = FlowTransactionScheduler.estimate(
                data: executionData,
                timestamp: executionTime,
                priority: pr,
                executionEffort: executionEffort
            )
            
            if estimate.timestamp == nil && pr != FlowTransactionScheduler.Priority.Low {
                panic("Failed to estimate fees for execution ".concat(i.toString()).concat(": ").concat(estimate.error ?? "unknown error"))
            }
            
            let fee = estimate.flowFee ?? 0.0
            totalFees = totalFees + fee
            
            // Withdraw fees for this execution
            let fees <- vaultRef.withdraw(amount: fee) as! @FlowToken.Vault
            
            // Schedule this execution
            manager.schedule(
                handlerCap: handlerCap!,
                data: executionData,
                timestamp: executionTime,
                priority: pr,
                executionEffort: executionEffort,
                fees: <-fees
            )
            
            log("Scheduled execution ".concat(i.toString()).concat(" at timestamp ").concat(executionTime.toString()))
            
            i = i + 1
        }
        
        log("Successfully scheduled ".concat(numberOfExecutions.toString()).concat(" executions"))
        log("Total fees paid: ".concat(totalFees.toString()).concat(" FLOW"))
    }
    
    execute {
        log("Multiple DCA executions scheduled successfully!")
    }
}

