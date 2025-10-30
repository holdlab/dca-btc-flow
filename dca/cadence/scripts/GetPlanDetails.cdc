import "DCAContract"

/// GetPlanDetails - Get details for a specific DCA plan
/// 
/// Parameters:
/// - userAddress: The address of the plan owner
/// - planId: The ID of the plan
/// 
/// Returns: PlanDetails struct or nil if not found
access(all) fun main(userAddress: Address, planId: UInt64): DCAContract.PlanDetails? {
    let account = getAccount(userAddress)
    
    // Get the PlanManager capability
    let planManagerCap = account.capabilities
        .get<&DCAContract.PlanManager>(DCAContract.PlanManagerPublicPath)
    
    if planManagerCap == nil {
        return nil
    }

    let planManager = planManagerCap!.borrow()
    if planManager == nil {
        return nil
    }

    // Get the specific plan
    let plan = planManager!.borrowPlan(planId: planId)
    if plan == nil {
        return nil
    }

    return plan!.getPlanDetails()
}

