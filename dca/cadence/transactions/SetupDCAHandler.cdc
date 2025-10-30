import "DCATransactionHandler"
import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"

/// Sets up the DCA Transaction Handler and Manager in the user's account
/// This follows the official Flow scheduled transactions pattern where
/// each user stores their own Handler resource
transaction() {
    prepare(signer: auth(Storage, Capabilities) &Account) {
        
        // Setup DCA transaction handler
        // Always recreate to ensure capabilities are set up correctly
        if signer.storage.check<@DCATransactionHandler.Handler>(
            from: DCATransactionHandler.HandlerStoragePath
        ) {
            // Unpublish old capability
            signer.capabilities.unpublish(DCATransactionHandler.HandlerPublicPath)

            // Remove existing handler
            let oldHandler <- signer.storage.load<@DCATransactionHandler.Handler>(
                from: DCATransactionHandler.HandlerStoragePath
            )
            destroy oldHandler
            log("Removed existing handler")
        }

        // Create and save new handler
        let handler <- DCATransactionHandler.createHandler()
        signer.storage.save(<-handler, to: DCATransactionHandler.HandlerStoragePath)

        // Issue entitled capability for FlowTransactionScheduler
        // This is the capability that will be used for scheduling
        let entitledCap = signer.capabilities.storage
            .issue<auth(FlowTransactionScheduler.Execute) &{FlowTransactionScheduler.TransactionHandler}>(
                DCATransactionHandler.HandlerStoragePath
            )

        // Also issue and publish a non-entitled public capability for verification
        let publicCap = signer.capabilities.storage
            .issue<&{FlowTransactionScheduler.TransactionHandler}>(DCATransactionHandler.HandlerStoragePath)
        signer.capabilities.publish(publicCap, at: DCATransactionHandler.HandlerPublicPath)

        log("DCA Transaction Handler setup complete with entitled capability")
        
        // Setup Manager if not already set up
        if !signer.storage.check<@{FlowTransactionSchedulerUtils.Manager}>(
            from: FlowTransactionSchedulerUtils.managerStoragePath
        ) {
            let manager <- FlowTransactionSchedulerUtils.createManager()
            signer.storage.save(<-manager, to: FlowTransactionSchedulerUtils.managerStoragePath)
            
            // Create a public capability to the manager
            let managerCap = signer.capabilities.storage
                .issue<&{FlowTransactionSchedulerUtils.Manager}>(FlowTransactionSchedulerUtils.managerStoragePath)
            signer.capabilities.publish(managerCap, at: FlowTransactionSchedulerUtils.managerPublicPath)
            
            log("Manager setup complete")
        } else {
            log("Manager already exists")
        }
    }
    
    execute {
        log("DCA Handler and Manager setup successful!")
    }
}

