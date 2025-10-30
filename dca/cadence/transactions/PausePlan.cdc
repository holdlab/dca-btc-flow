import "DCAContract"

/// PausePlan - Pause a DCA plan
/// 
/// Parameters:
/// - planId: The ID of the plan to pause
transaction(planId: UInt64) {
    prepare(signer: auth(Storage) &Account) {
        // Borrow PlanManager
        let planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found")

        // Borrow the plan
        let plan = planManager.borrowPlan(planId: planId)
            ?? panic("Plan not found")

        // Pause the plan
        plan.pause()

        log("Plan ".concat(planId.toString()).concat(" paused"))
    }
}

