import "FlowTransactionScheduler"
import "FlowTransactionSchedulerUtils"
import "DCAContract"
import "FungibleToken"
import "FlowToken"
import "SimpleSwap"
import "MockBTC"

access(all) contract DCATransactionHandler {

    access(all) event SwapExecuted(planId: UInt64, owner: Address, amountIn: UFix64, amountOut: UFix64)
    access(all) event SwapFailed(planId: UInt64, owner: Address, reason: String)
    access(all) event NextExecutionScheduled(planId: UInt64, scheduledTime: UFix64)

    access(all) struct ExecutionData {
        access(all) let planOwner: Address
        access(all) let planId: UInt64
        access(all) let slippageTolerance: UFix64

        init(planOwner: Address, planId: UInt64, slippageTolerance: UFix64) {
            self.planOwner = planOwner
            self.planId = planId
            self.slippageTolerance = slippageTolerance
        }
    }

    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {
        
        access(FlowTransactionScheduler.Execute)
        fun executeTransaction(id: UInt64, data: AnyStruct?) {
            let executionData = data as! ExecutionData?
                ?? panic("Invalid execution data")

            log("Executing DCA plan ".concat(executionData.planId.toString()))

            let ownerAccount = getAccount(executionData.planOwner)
            let planManagerCap = ownerAccount.capabilities
                .get<&DCAContract.PlanManager>(DCAContract.PlanManagerPublicPath)

            if planManagerCap == nil {
                emit SwapFailed(
                    planId: executionData.planId,
                    owner: executionData.planOwner,
                    reason: "Plan manager capability not found"
                )
                return
            }

            let planManager = planManagerCap!.borrow()
            if planManager == nil {
                emit SwapFailed(
                    planId: executionData.planId,
                    owner: executionData.planOwner,
                    reason: "Could not borrow plan manager"
                )
                return
            }

            let plan = planManager!.borrowPlanWithExecute(planId: executionData.planId)
            if plan == nil {
                emit SwapFailed(
                    planId: executionData.planId,
                    owner: executionData.planOwner,
                    reason: "Plan not found"
                )
                return
            }

            if !plan!.canExecute() {
                log("Plan cannot execute - skipping")
                return
            }

            // Execute the swap
            self.executeSwap(plan: plan!, data: executionData)

            // Schedule next execution if plan is still active
            self.scheduleNextExecution(plan: plan!, data: executionData, ownerAccount: ownerAccount)
        }

        access(self) fun scheduleNextExecution(
            plan: &DCAContract.DCAplan,
            data: ExecutionData,
            ownerAccount: &Account
        ) {
            // Check if plan is still active
            if !plan.isActive || plan.isPaused {
                log("Plan is not active or paused - not scheduling next execution")
                return
            }

            // Calculate next execution time
            let nextExecutionTime = getCurrentBlock().timestamp + plan.timeCycle

            // Emit event indicating when next execution should occur
            // The user needs to manually schedule or use a keeper service
            // because the Handler can't access the owner's storage to withdraw fees
            emit NextExecutionScheduled(planId: data.planId, scheduledTime: nextExecutionTime)
            log("Next execution should occur at ".concat(nextExecutionTime.toString()))
            log("User must schedule the next execution manually or use a keeper service")
        }

        access(self) fun executeSwap(plan: auth(DCAContract.Execute) &DCAContract.DCAplan, data: ExecutionData) {
            // Withdraw USD from the plan
            let usdVault <- plan.withdrawForSwap()
            let amountIn = usdVault.balance

            // Execute swap: USD -> BTC
            let btcVault <- SimpleSwap.swapUSDForBTC(
                usdVault: <-usdVault,
                recipient: data.planOwner
            )
            let amountOut = btcVault.balance

            // Deposit BTC to user's account
            let ownerAccount = getAccount(data.planOwner)
            let btcReceiverCap = ownerAccount.capabilities
                .get<&{FungibleToken.Vault}>(MockBTC.VaultPublicPath)

            if let btcReceiver = btcReceiverCap.borrow() {
                btcReceiver.deposit(from: <-btcVault)
            } else {
                // If user doesn't have BTC vault, destroy the tokens
                // In production, you might want to handle this differently
                destroy btcVault
            }

            // Record execution
            plan.recordExecution(amountOut: amountOut)

            emit SwapExecuted(
                planId: data.planId,
                owner: data.planOwner,
                amountIn: amountIn,
                amountOut: amountOut
            )
        }

        access(all) view fun getViews(): [Type] {
            return [Type<StoragePath>(), Type<PublicPath>()]
        }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<StoragePath>():
                    return DCATransactionHandler.HandlerStoragePath
                case Type<PublicPath>():
                    return DCATransactionHandler.HandlerPublicPath
                default:
                    return nil
            }
        }
    }

    access(all) let HandlerStoragePath: StoragePath
    access(all) let HandlerPublicPath: PublicPath

    access(all) fun createHandler(): @Handler {
        return <- create Handler()
    }

    init() {
        self.HandlerStoragePath = /storage/DCATransactionHandler
        self.HandlerPublicPath = /public/DCATransactionHandler
    }
}
