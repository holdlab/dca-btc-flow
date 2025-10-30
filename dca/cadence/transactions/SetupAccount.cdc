import "DCAContract"
import "FungibleToken"
import "FlowToken"

/// SetupAccount - Initialize user account for DCA
/// This transaction sets up the necessary resources and capabilities
/// for a user to create and manage DCA plans
transaction {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Check if PlanManager already exists
        if signer.storage.borrow<&DCAContract.PlanManager>(
            from: DCAContract.PlanManagerStoragePath
        ) != nil {
            log("PlanManager already exists")
            return
        }

        // Create and save PlanManager
        let manager <- DCAContract.createPlanManager()
        signer.storage.save(<-manager, to: DCAContract.PlanManagerStoragePath)

        // Create and publish public capability
        let cap = signer.capabilities.storage.issue<&DCAContract.PlanManager>(
            DCAContract.PlanManagerStoragePath
        )
        signer.capabilities.publish(cap, at: DCAContract.PlanManagerPublicPath)

        log("Account setup complete!")
    }

    execute {
        log("DCA account initialized successfully")
    }
}

