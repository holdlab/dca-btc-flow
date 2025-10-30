import "DCAContract"

/// StopPlan - Stop a DCA plan permanently
/// 
/// Parameters:
/// - planId: The ID of the plan to stop
transaction(planId: UInt64) {
    prepare(signer: auth(Storage) &Account) {
        // Borrow PlanManager
        let planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found")

        // Borrow the plan
        let plan = planManager.borrowPlan(planId: planId)
            ?? panic("Plan not found")

        // Stop the plan
        plan.stop()

        log("Plan ".concat(planId.toString()).concat(" stopped"))
    }
}

