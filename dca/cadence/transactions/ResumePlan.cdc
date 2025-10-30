import "DCAContract"

/// ResumePlan - Resume a paused DCA plan
/// 
/// Parameters:
/// - planId: The ID of the plan to resume
transaction(planId: UInt64) {
    prepare(signer: auth(Storage) &Account) {
        // Borrow PlanManager
        let planManager = signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) ?? panic("PlanManager not found")

        // Borrow the plan
        let plan = planManager.borrowPlan(planId: planId)
            ?? panic("Plan not found")

        // Resume the plan
        plan.resume()

        log("Plan ".concat(planId.toString()).concat(" resumed"))
    }
}

