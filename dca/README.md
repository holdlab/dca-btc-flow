# DCA Protocol on Flow Blockchain

A Dollar Cost Averaging (DCA) protocol built with Cadence on Flow blockchain, featuring **native scheduled transactions** for automatic recurring executions.

## 🌟 Features

- ✅ **Native Cadence Implementation** - Built with Cadence 1.0, not EVM
- ✅ **Resource-Based Ownership** - Secure fund management using Cadence resources
- ✅ **Scheduled Transactions** - Automatic execution using Flow's native scheduler (no keeper bots!)
- ✅ **Real Token Swaps** - Integrated with SimpleSwap DEX
- ✅ **Entitlement-Based Access Control** - Fine-grained security
- ✅ **Production Ready** - Deployed and tested on Flow Testnet

## 📍 Deployed Contracts (Testnet)

| Contract | Address | Description |
|----------|---------|-------------|
| **DCAContract** | `0x78acd984694957cf` | Main DCA protocol contract |
| **DCATransactionHandler** | `0x78acd984694957cf` | Scheduled transaction handler |
| **MockUSD** | `0x78acd984694957cf` | Test USD token |
| **MockBTC** | `0x78acd984694957cf` | Test BTC token |
| **SimpleSwap** | `0x78acd984694957cf` | Simple DEX for swaps |
| **FlowTransactionScheduler** | `0x8c5303eaa26202d6` | Flow's native scheduler |
| **FlowTransactionSchedulerUtils** | `0x8c5303eaa26202d6` | Scheduler utilities |

**View on Flowscan:**
- [DCAContract](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCAContract)
- [DCATransactionHandler](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCATransactionHandler)

## 🚀 Quick Start

### Prerequisites
- Flow CLI installed ([Installation Guide](https://developers.flow.com/build/tools/flow-cli/install))
- Flow account with testnet FLOW tokens

### 1. Setup Your Account (One-time)

```bash
# Setup account with mock tokens
flow transactions send cadence/transactions/SetupAccount.cdc \
  --signer testnet-account \
  --network testnet

# Setup mock tokens (1000 USD, 0 BTC)
flow transactions send cadence/transactions/SetupMockTokens.cdc \
  1000.0 0.0 \
  --signer testnet-account \
  --network testnet

# Setup DCA Handler for scheduled transactions
flow transactions send cadence/transactions/SetupDCAHandler.cdc \
  --signer testnet-account \
  --network testnet
```

### 2. Create a DCA Plan

```bash
# Create a plan: 10 USD every 60 seconds, 100 USD total
flow transactions send cadence/transactions/CreateDCAPlanWithMockUSD.cdc \
  10.0 60.0 100.0 \
  --signer testnet-account \
  --network testnet
```

### 3. Schedule Automatic Execution

```bash
# Schedule execution in 60 seconds with medium priority
flow transactions send cadence/transactions/ScheduleDCAExecution.cdc \
  1 60.0 1 1000 \
  --signer testnet-account \
  --network testnet
```

### 4. Monitor Your Scheduled Transaction

```bash
# List all scheduled transactions
flow schedule list <your-address> --network testnet

# Check plan details
flow scripts execute cadence/scripts/GetPlanDetails.cdc \
  <your-address> 1 \
  --network testnet

# Check token balances
flow scripts execute cadence/scripts/GetTokenBalances.cdc \
  <your-address> \
  --network testnet
```

## 📖 Available Transactions

### Account Setup
- `SetupAccount.cdc` - Initialize DCA account resources
- `SetupMockTokens.cdc` - Mint test tokens (USD and BTC)
- `SetupDCAHandler.cdc` - Setup scheduled transaction handler

### DCA Plan Management
- `CreateDCAPlanWithMockUSD.cdc` - Create a new DCA plan
- `DepositToPlan.cdc` - Add funds to existing plan
- `PausePlan.cdc` - Pause a plan
- `ResumePlan.cdc` - Resume a paused plan
- `StopPlan.cdc` - Stop and close a plan

### Scheduled Execution
- `ScheduleDCAExecution.cdc` - Schedule automatic execution
- `ManualExecuteSwap.cdc` - Manually trigger a swap (for testing)

### Query Scripts
- `GetPlanDetails.cdc` - View plan information
- `GetUserPlans.cdc` - List all user's plans
- `GetTokenBalances.cdc` - Check USD and BTC balances

## 🏗️ Architecture

### Core Contracts

**DCAContract.cdc**
- Main protocol managing DCA plans
- Resource-based ownership model
- Entitlement-based access control
- Supports pause/resume/stop operations

**DCATransactionHandler.cdc**
- Implements `FlowTransactionScheduler.TransactionHandler`
- Executes swaps when scheduled time arrives
- Each user stores their own Handler instance
- Automatic execution via Flow's native scheduler

**SimpleSwap.cdc**
- Simple DEX with fixed exchange rate (1 BTC = 50,000 USD)
- Handles USD → BTC swaps
- Used for testing and demonstration

### Scheduled Transactions Flow

```
User creates plan → User schedules execution → Flow stores transaction
                                                        ↓
User receives BTC ← Swap executes ← Handler called ← Time arrives
```

## 💰 Fee Structure

Scheduled transaction fees are based on:
- **Priority Level**:
  - High (0): 10x base rate - Guaranteed first block execution
  - Medium (1): 5x base rate - Best-effort execution
  - Low (2): 2x base rate - Opportunistic execution
- **Execution Effort**: Gas limit for the transaction
- **Storage**: Cost for storing transaction data

**Typical testnet fees**: ~0.001 FLOW for medium priority

## 🔧 Advanced Usage

### Cancel a Scheduled Transaction
```bash
flow schedule cancel <transaction-id> --network testnet
```
Returns 50% refund of fees paid.

### Monitor Events
```bash
flow events get \
  A.8c5303eaa26202d6.FlowTransactionScheduler.Scheduled \
  A.8c5303eaa26202d6.FlowTransactionScheduler.Executed \
  A.78acd984694957cf.DCATransactionHandler.SwapExecuted \
  --last 100 \
  --network testnet
```

### View All Scheduled Transactions
```bash
flow schedule list <your-address> --network testnet
```

## 📦 Project Structure

```
dca/
├── flow.json                          # Project configuration
├── README.md                          # This file
├── SCHEDULED_TRANSACTIONS_SUCCESS.md  # Implementation guide
├── SCHEDULED_TRANSACTIONS_CLI_GUIDE.md # CLI reference
├── cadence/
│   ├── contracts/
│   │   ├── DCAContract.cdc           # Main DCA protocol
│   │   ├── DCATransactionHandler.cdc # Scheduled transaction handler
│   │   ├── MockUSD.cdc               # Test USD token
│   │   ├── MockBTC.cdc               # Test BTC token
│   │   └── SimpleSwap.cdc            # Simple DEX
│   ├── transactions/
│   │   ├── SetupAccount.cdc          # Account initialization
│   │   ├── SetupMockTokens.cdc       # Mint test tokens
│   │   ├── SetupDCAHandler.cdc       # Setup scheduler handler
│   │   ├── CreateDCAPlanWithMockUSD.cdc # Create DCA plan
│   │   ├── ScheduleDCAExecution.cdc  # Schedule execution
│   │   ├── ManualExecuteSwap.cdc     # Manual swap trigger
│   │   ├── PausePlan.cdc             # Pause plan
│   │   ├── ResumePlan.cdc            # Resume plan
│   │   ├── StopPlan.cdc              # Stop plan
│   │   └── DepositToPlan.cdc         # Add funds
│   └── scripts/
│       ├── GetPlanDetails.cdc        # View plan info
│       ├── GetUserPlans.cdc          # List user's plans
│       └── GetTokenBalances.cdc      # Check balances
```


## 🧪 Testing

### Testnet Testing (Recommended)
The protocol is deployed and tested on Flow Testnet. Follow the Quick Start guide above.

### Local Emulator Testing
```bash
# Start emulator
flow emulator --block-time 1s

# Deploy contracts
flow project deploy --network emulator

# Run transactions (replace --network testnet with --network emulator)
```

## 🛠️ Development

### Deploy to Testnet
```bash
# Update flow.json with your account
# Deploy contracts
flow project deploy --network testnet --update
```

### Update Contracts
```bash
flow project deploy --network testnet --update
```

## 📚 Documentation

- **[SCHEDULED_TRANSACTIONS_SUCCESS.md](./SCHEDULED_TRANSACTIONS_SUCCESS.md)** - Complete implementation guide
- **[SCHEDULED_TRANSACTIONS_CLI_GUIDE.md](./SCHEDULED_TRANSACTIONS_CLI_GUIDE.md)** - CLI command reference
- **[Flow Scheduled Transactions](https://developers.flow.com/build/cadence/advanced-concepts/scheduled-transactions)** - Official Flow docs
- **[Flow CLI](https://developers.flow.com/build/tools/flow-cli/scheduled-transactions)** - CLI documentation

## 🔗 Resources

### Flow Blockchain
- **[Flow Documentation](https://developers.flow.com/)** - Official Flow documentation
- **[Cadence Language](https://cadence-lang.org/docs/language)** - Cadence programming language
- **[Flow Testnet Faucet](https://testnet-faucet.onflow.org/)** - Get testnet FLOW tokens
- **[Flowscan Testnet](https://testnet.flowscan.io/)** - Block explorer

### Development Tools
- **[Flow CLI](https://developers.flow.com/build/tools/flow-cli)** - Command-line interface
- **[VS Code Cadence Extension](https://marketplace.visualstudio.com/items?itemName=onflow.cadence)** - IDE support
- **[Flow Clients](https://developers.flow.com/tools/clients)** - SDKs for various languages

## 🤝 Contributing

This is a demonstration project showcasing Flow's scheduled transactions feature. Feel free to:
- Report issues
- Suggest improvements
- Fork and extend

## 📄 License

This project is open source and available for educational purposes.

## 🎉 Acknowledgments

Built using:
- Flow Blockchain
- Cadence 1.0
- Flow Scheduled Transactions (FLIP 330)
- Flow CLI

---

**Ready to build your own DCA protocol on Flow?** Start with the Quick Start guide above! 🚀
