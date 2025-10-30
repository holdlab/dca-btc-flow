import "DCAContract"

/// GetUserPlans - Get all DCA plans for a user
/// 
/// Parameters:
/// - userAddress: The address of the user
/// 
/// Returns: Array of PlanDetails structs
access(all) fun main(userAddress: Address): [DCAContract.PlanDetails] {
    let account = getAccount(userAddress)
    
    // Get the PlanManager capability
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
    let plans: [DCAContract.PlanDetails] = []

    // Get details for each plan
    for planId in planIds {
        let plan = planManager!.borrowPlan(planId: planId)
        if plan != nil {
            plans.append(plan!.getPlanDetails())
        }
    }

    return plans
}

