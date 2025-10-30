import "FungibleToken"
import "FlowToken"
import "FlowTransactionSchedulerUtils"

/// DCAContract - Dollar Cost Averaging on Flow
/// Allows users to create automated recurring purchases of one token with another
/// Uses Flow's native Scheduled Transactions for automation (no keeper bot needed!)
access(all) contract DCAContract {

    // ========================================
    // Paths
    // ========================================
    
    access(all) let PlanManagerStoragePath: StoragePath
    access(all) let PlanManagerPublicPath: PublicPath

    // ========================================
    // Constants
    // ========================================
    
    access(all) let ONE_HOUR: UFix64
    access(all) let ONE_DAY: UFix64

    // ========================================
    // Events
    // ========================================
    
    access(all) event PlanCreated(
        planId: UInt64,
        owner: Address,
        amountPerExecution: UFix64,
        timeCycle: UFix64,
        maxExecutions: UInt64
    )

    access(all) event PlanExecuted(
        planId: UInt64,
        owner: Address,
        amountIn: UFix64,
        amountOut: UFix64,
        executionNumber: UInt64
    )

    access(all) event PlanStopped(
        planId: UInt64,
        owner: Address
    )

    access(all) event PlanPaused(
        planId: UInt64,
        owner: Address
    )

    access(all) event PlanResumed(
        planId: UInt64,
        owner: Address
    )

    // ========================================
    // Interfaces
    // ========================================

    /// Public interface for DCA plans
    access(all) resource interface PlanPublic {
        access(all) fun getPlanDetails(): PlanDetails
        access(all) fun canExecute(): Bool
        access(all) fun getNextExecutionTime(): UFix64
    }

    /// Owner interface for DCA plans
    access(all) resource interface PlanOwner {
        access(all) fun stop()
        access(all) fun pause()
        access(all) fun resume()
        access(all) fun depositFunds(vault: @{FungibleToken.Vault})
        access(all) fun withdrawRemainingFunds(): @{FungibleToken.Vault}
    }

    // ========================================
    // Structs
    // ========================================

    access(all) struct PlanDetails {
        access(all) let planId: UInt64
        access(all) let owner: Address
        access(all) let amountPerExecution: UFix64
        access(all) let timeCycle: UFix64
        access(all) let lastExecution: UFix64
        access(all) let totalExecutions: UInt64
        access(all) let maxExecutions: UInt64
        access(all) let isActive: Bool
        access(all) let isPaused: Bool
        access(all) let createdAt: UFix64
        access(all) let balance: UFix64

        init(
            planId: UInt64,
            owner: Address,
            amountPerExecution: UFix64,
            timeCycle: UFix64,
            lastExecution: UFix64,
            totalExecutions: UInt64,
            maxExecutions: UInt64,
            isActive: Bool,
            isPaused: Bool,
            createdAt: UFix64,
            balance: UFix64
        ) {
            self.planId = planId
            self.owner = owner
            self.amountPerExecution = amountPerExecution
            self.timeCycle = timeCycle
            self.lastExecution = lastExecution
            self.totalExecutions = totalExecutions
            self.maxExecutions = maxExecutions
            self.isActive = isActive
            self.isPaused = isPaused
            self.createdAt = createdAt
            self.balance = balance
        }
    }

    // ========================================
    // Resources
    // ========================================

    /// DCA Plan Resource
    /// Stores the plan configuration and the USD vault for swaps
    access(all) resource DCAplan: PlanPublic, PlanOwner {
        access(all) let planId: UInt64
        access(all) let owner: Address
        access(all) let amountPerExecution: UFix64
        access(all) let timeCycle: UFix64
        access(all) var lastExecution: UFix64
        access(all) var totalExecutions: UInt64
        access(all) let maxExecutions: UInt64
        access(all) var isActive: Bool
        access(all) var isPaused: Bool
        access(all) let createdAt: UFix64
        
        // Vault to hold USD tokens for swaps
        access(self) let usdVault: @{FungibleToken.Vault}

        init(
            planId: UInt64,
            owner: Address,
            amountPerExecution: UFix64,
            timeCycle: UFix64,
            maxExecutions: UInt64,
            initialDeposit: @{FungibleToken.Vault}
        ) {
            pre {
                amountPerExecution > 0.0: "Amount must be greater than 0"
                timeCycle == DCAContract.ONE_HOUR || timeCycle == DCAContract.ONE_DAY: 
                    "Invalid time cycle - must be ONE_HOUR or ONE_DAY"
                initialDeposit.balance >= amountPerExecution: 
                    "Initial deposit must be at least amountPerExecution"
            }

            self.planId = planId
            self.owner = owner
            self.amountPerExecution = amountPerExecution
            self.timeCycle = timeCycle
            self.lastExecution = 0.0
            self.totalExecutions = 0
            self.maxExecutions = maxExecutions
            self.isActive = true
            self.isPaused = false
            self.createdAt = getCurrentBlock().timestamp
            self.usdVault <- initialDeposit
        }

        // ========================================
        // PlanPublic Implementation
        // ========================================

        access(all) fun getPlanDetails(): PlanDetails {
            return PlanDetails(
                planId: self.planId,
                owner: self.owner,
                amountPerExecution: self.amountPerExecution,
                timeCycle: self.timeCycle,
                lastExecution: self.lastExecution,
                totalExecutions: self.totalExecutions,
                maxExecutions: self.maxExecutions,
                isActive: self.isActive,
                isPaused: self.isPaused,
                createdAt: self.createdAt,
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

            if self.maxExecutions > 0 && self.totalExecutions >= self.maxExecutions {
                return false
            }

            let currentTime = getCurrentBlock().timestamp
            if self.lastExecution == 0.0 {
                return true
            }

            return currentTime >= self.lastExecution + self.timeCycle
        }

        access(all) fun getNextExecutionTime(): UFix64 {
            if self.lastExecution == 0.0 {
                return getCurrentBlock().timestamp
            }
            return self.lastExecution + self.timeCycle
        }

        // ========================================
        // PlanOwner Implementation
        // ========================================

        access(all) fun stop() {
            self.isActive = false
            emit PlanStopped(planId: self.planId, owner: self.owner)
        }

        access(all) fun pause() {
            pre {
                self.isActive: "Plan is not active"
                !self.isPaused: "Plan is already paused"
            }
            self.isPaused = true
            emit PlanPaused(planId: self.planId, owner: self.owner)
        }

        access(all) fun resume() {
            pre {
                self.isActive: "Plan is not active"
                self.isPaused: "Plan is not paused"
            }
            self.isPaused = false
            emit PlanResumed(planId: self.planId, owner: self.owner)
        }

        access(all) fun depositFunds(vault: @{FungibleToken.Vault}) {
            pre {
                vault.balance > 0.0: "Deposit amount must be greater than 0"
            }
            self.usdVault.deposit(from: <-vault)
        }

        access(all) fun withdrawRemainingFunds(): @{FungibleToken.Vault} {
            let amount = self.usdVault.balance
            return <- self.usdVault.withdraw(amount: amount)
        }

        // ========================================
        // Internal Functions (called by handler)
        // ========================================

        access(contract) fun withdrawForSwap(): @{FungibleToken.Vault} {
            pre {
                self.canExecute(): "Plan cannot be executed"
            }
            return <- self.usdVault.withdraw(amount: self.amountPerExecution)
        }

        access(contract) fun recordExecution(amountOut: UFix64) {
            self.lastExecution = getCurrentBlock().timestamp
            self.totalExecutions = self.totalExecutions + 1

            // Auto-stop if max executions reached
            if self.maxExecutions > 0 && self.totalExecutions >= self.maxExecutions {
                self.isActive = false
            }

            emit PlanExecuted(
                planId: self.planId,
                owner: self.owner,
                amountIn: self.amountPerExecution,
                amountOut: amountOut,
                executionNumber: self.totalExecutions
            )
        }
    }

    /// Plan Manager Resource
    /// Manages all DCA plans for a user
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
            maxExecutions: UInt64,
            initialDeposit: @{FungibleToken.Vault}
        ): UInt64 {
            let planId = self.nextPlanId
            self.nextPlanId = self.nextPlanId + 1

            let plan <- create DCAplan(
                planId: planId,
                owner: self.owner!.address,
                amountPerExecution: amountPerExecution,
                timeCycle: timeCycle,
                maxExecutions: maxExecutions,
                initialDeposit: <-initialDeposit
            )

            emit PlanCreated(
                planId: planId,
                owner: self.owner!.address,
                amountPerExecution: amountPerExecution,
                timeCycle: timeCycle,
                maxExecutions: maxExecutions
            )

            self.plans[planId] <-! plan
            return planId
        }

        access(all) fun borrowPlan(planId: UInt64): &DCAplan? {
            return &self.plans[planId]
        }

        access(all) fun getPlanIds(): [UInt64] {
            return self.plans.keys
        }

        access(all) fun destroyPlan(planId: UInt64) {
            destroy self.plans.remove(key: planId)
        }
    }

    // ========================================
    // Contract Functions
    // ========================================

    access(all) fun createPlanManager(): @PlanManager {
        return <- create PlanManager()
    }

    init() {
        self.PlanManagerStoragePath = /storage/DCAPlanManager
        self.PlanManagerPublicPath = /public/DCAPlanManager
        
        self.ONE_HOUR = 3600.0
        self.ONE_DAY = 86400.0
    }
}

