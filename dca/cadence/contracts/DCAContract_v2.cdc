import "FungibleToken"
import "FlowToken"

/// DCAContract - Dollar Cost Averaging on Flow
/// Simplified version compatible with Cadence 1.0
access(all) contract DCAContract {

    // ========================================
    // Entitlements
    // ========================================

    /// Entitlement for executing DCA swaps
    access(all) entitlement Execute

    // ========================================
    // Paths
    // ========================================

    access(all) let PlanManagerStoragePath: StoragePath
    access(all) let PlanManagerPublicPath: PublicPath

    // ========================================
    // Events
    // ========================================
    
    access(all) event PlanCreated(
        planId: UInt64,
        owner: Address,
        amountPerExecution: UFix64,
        timeCycle: UFix64
    )

    access(all) event PlanExecuted(
        planId: UInt64,
        owner: Address,
        amountIn: UFix64,
        amountOut: UFix64
    )

    access(all) event PlanStopped(planId: UInt64, owner: Address)
    access(all) event PlanPaused(planId: UInt64, owner: Address)
    access(all) event PlanResumed(planId: UInt64, owner: Address)

    // ========================================
    // Structs
    // ========================================
    
    access(all) struct PlanDetails {
        access(all) let planId: UInt64
        access(all) let ownerAddress: Address
        access(all) let amountPerExecution: UFix64
        access(all) let timeCycle: UFix64
        access(all) let lastExecution: UFix64
        access(all) let totalExecutions: UInt64
        access(all) let isActive: Bool
        access(all) let isPaused: Bool
        access(all) let balance: UFix64

        init(
            planId: UInt64,
            ownerAddress: Address,
            amountPerExecution: UFix64,
            timeCycle: UFix64,
            lastExecution: UFix64,
            totalExecutions: UInt64,
            isActive: Bool,
            isPaused: Bool,
            balance: UFix64
        ) {
            self.planId = planId
            self.ownerAddress = ownerAddress
            self.amountPerExecution = amountPerExecution
            self.timeCycle = timeCycle
            self.lastExecution = lastExecution
            self.totalExecutions = totalExecutions
            self.isActive = isActive
            self.isPaused = isPaused
            self.balance = balance
        }
    }

    // ========================================
    // Interfaces
    // ========================================
    
    access(all) resource interface PlanPublic {
        access(all) fun getPlanDetails(): PlanDetails
        access(all) fun canExecute(): Bool
    }

    access(all) resource interface PlanOwner {
        access(all) fun stop()
        access(all) fun pause()
        access(all) fun resume()
        access(all) fun depositFunds(vault: @{FungibleToken.Vault})
        access(all) fun withdrawRemainingFunds(): @{FungibleToken.Vault}
    }

    access(all) resource interface PlanExecutor {
        access(Execute) fun withdrawForSwap(): @{FungibleToken.Vault}
        access(Execute) fun recordExecution(amountOut: UFix64)
    }

    // ========================================
    // Resources
    // ========================================

    /// DCA Plan Resource
    access(all) resource DCAplan: PlanPublic, PlanOwner, PlanExecutor {
        access(all) let planId: UInt64
        access(all) let ownerAddress: Address
        access(all) let amountPerExecution: UFix64
        access(all) let timeCycle: UFix64
        access(all) var lastExecution: UFix64
        access(all) var totalExecutions: UInt64
        access(all) var isActive: Bool
        access(all) var isPaused: Bool
        
        access(self) let usdVault: @{FungibleToken.Vault}

        init(
            planId: UInt64,
            ownerAddress: Address,
            amountPerExecution: UFix64,
            timeCycle: UFix64,
            initialDeposit: @{FungibleToken.Vault}
        ) {
            self.planId = planId
            self.ownerAddress = ownerAddress
            self.amountPerExecution = amountPerExecution
            self.timeCycle = timeCycle
            self.lastExecution = 0.0
            self.totalExecutions = 0
            self.isActive = true
            self.isPaused = false
            self.usdVault <- initialDeposit
        }

        access(all) fun getPlanDetails(): PlanDetails {
            return PlanDetails(
                planId: self.planId,
                ownerAddress: self.ownerAddress,
                amountPerExecution: self.amountPerExecution,
                timeCycle: self.timeCycle,
                lastExecution: self.lastExecution,
                totalExecutions: self.totalExecutions,
                isActive: self.isActive,
                isPaused: self.isPaused,
                balance: self.usdVault.balance
            )
        }

        access(all) fun canExecute(): Bool {
            if !self.isActive || self.isPaused {
                return false
            }
            
            if self.usdVault.balance < self.amountPerExecution {
                return false
            }
            
            let currentTime = getCurrentBlock().timestamp
            let timeSinceLastExecution = currentTime - self.lastExecution
            
            return timeSinceLastExecution >= self.timeCycle
        }

        access(Execute) fun withdrawForSwap(): @{FungibleToken.Vault} {
            pre {
                self.isActive: "Plan is not active"
                !self.isPaused: "Plan is paused"
                self.usdVault.balance >= self.amountPerExecution: "Insufficient balance"
            }
            return <- self.usdVault.withdraw(amount: self.amountPerExecution)
        }

        access(Execute) fun recordExecution(amountOut: UFix64) {
            self.lastExecution = getCurrentBlock().timestamp
            self.totalExecutions = self.totalExecutions + 1
            
            emit PlanExecuted(
                planId: self.planId,
                owner: self.ownerAddress,
                amountIn: self.amountPerExecution,
                amountOut: amountOut
            )
        }

        access(all) fun stop() {
            self.isActive = false
            emit PlanStopped(planId: self.planId, owner: self.ownerAddress)
        }

        access(all) fun pause() {
            self.isPaused = true
            emit PlanPaused(planId: self.planId, owner: self.ownerAddress)
        }

        access(all) fun resume() {
            self.isPaused = false
            emit PlanResumed(planId: self.planId, owner: self.ownerAddress)
        }

        access(all) fun depositFunds(vault: @{FungibleToken.Vault}) {
            self.usdVault.deposit(from: <-vault)
        }

        access(all) fun withdrawRemainingFunds(): @{FungibleToken.Vault} {
            let balance = self.usdVault.balance
            return <- self.usdVault.withdraw(amount: balance)
        }
    }

    /// Plan Manager Resource
    access(all) resource PlanManager {
        access(self) let plans: @{UInt64: DCAplan}
        access(all) var nextPlanId: UInt64

        init() {
            self.plans <- {}
            self.nextPlanId = 1
        }

        access(all) fun createPlan(
            amountPerExecution: UFix64,
            timeCycle: UFix64,
            initialDeposit: @{FungibleToken.Vault}
        ): UInt64 {
            let planId = self.nextPlanId
            self.nextPlanId = self.nextPlanId + 1

            let ownerAddress = self.owner?.address ?? panic("No owner")
            
            let plan <- create DCAplan(
                planId: planId,
                ownerAddress: ownerAddress,
                amountPerExecution: amountPerExecution,
                timeCycle: timeCycle,
                initialDeposit: <-initialDeposit
            )

            emit PlanCreated(
                planId: planId,
                owner: ownerAddress,
                amountPerExecution: amountPerExecution,
                timeCycle: timeCycle
            )

            self.plans[planId] <-! plan
            return planId
        }

        access(all) fun borrowPlan(planId: UInt64): &DCAplan? {
            return &self.plans[planId]
        }

        access(all) fun borrowPlanWithExecute(planId: UInt64): auth(Execute) &DCAplan? {
            return &self.plans[planId] as auth(Execute) &DCAplan?
        }

        access(all) fun getPlanIds(): [UInt64] {
            return self.plans.keys
        }

        access(all) fun destroyPlan(planId: UInt64) {
            destroy self.plans.remove(key: planId)
        }
    }

    /// Create a new Plan Manager
    access(all) fun createPlanManager(): @PlanManager {
        return <- create PlanManager()
    }

    init() {
        self.PlanManagerStoragePath = /storage/DCAPlanManager
        self.PlanManagerPublicPath = /public/DCAPlanManager
    }
}

