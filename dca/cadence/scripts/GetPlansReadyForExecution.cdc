import "DCAContract"

/// Get all DCA plans that are ready for execution
/// This script can be used by keeper bots to find plans that need execution
/// @param address: The address to check for plans
/// @return Array of plan IDs that are ready for execution
access(all) fun main(address: Address): [UInt64] {
    let account = getAccount(address)
    
    // Get the plan manager capability
    let planManagerCap = account.capabilities
        .get<&DCAContract.PlanManager>(DCAContract.PlanManagerPublicPath)
    
    if planManagerCap == nil {
        return []
    }
    
    let planManager = planManagerCap!.borrow()
    if planManager == nil {
        return []
    }
    
    // Get all plan IDs
    let planIds = planManager!.getPlanIds()
    var readyPlans: [UInt64] = []

    // Check each plan to see if it's ready for execution
    for planId in planIds {
        let plan = planManager!.borrowPlan(planId: planId)
        if plan == nil {
            continue
        }

        let planDetails = plan!.getPlanDetails()

        // Check if plan is active and not paused
        if !planDetails.isActive || planDetails.isPaused {
            continue
        }

        // Check if enough time has passed since last execution
        let currentTime = getCurrentBlock().timestamp
        let timeSinceLastExecution = currentTime - planDetails.lastExecution

        if timeSinceLastExecution >= planDetails.timeCycle {
            readyPlans.append(planDetails.planId)
        }
    }

    return readyPlans
}

