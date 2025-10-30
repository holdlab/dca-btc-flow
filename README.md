# DCA Protocol on Flow Blockchain

> **Automated Dollar Cost Averaging powered by Flow's native Scheduled Transactions**

## 🌟 Overview

A fully functional DCA (Dollar Cost Averaging) protocol built on Flow blockchain. This project leverages Flow's unique **Scheduled Transactions** feature to create a completely autonomous, decentralized DCA system that requires **no keeper bot infrastructure**.

### What is DCA?

Dollar Cost Averaging (DCA) is an investment strategy where you automatically purchase a fixed dollar amount of an asset at regular intervals, regardless of price. This reduces the impact of volatility and removes emotion from investing.

### Why Flow?

Flow's native **Scheduled Transactions** feature allows smart contracts to execute code at future times without external transactions. This makes Flow the **perfect blockchain for DCA** because:

- ✅ **No Keeper Bot Required** - Network executes automatically
- ✅ **Fully Decentralized** - No reliance on external infrastructure
- ✅ **More Reliable** - Network guarantees execution
- ✅ **Lower Costs** - No keeper fees or server hosting
- ✅ **True Automation** - Schedule multiple executions upfront

## 🎯 Current Status

**✅ FULLY DEPLOYED ON FLOW TESTNET**

- **Smart Contracts**: Deployed at `0x78acd984694957cf`
- **Frontend**: React app with Flow wallet integration
- **Telegram Bot**: Real-time execution notifications
- **Demo Script**: Complete walkthrough guide

**Live on Flow Testnet:**
- DCAContract: [View on Flowscan](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCAContract)
- DCATransactionHandler: [View on Flowscan](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCATransactionHandler)
- MockUSD & MockBTC: Test tokens for DCA testing

## 🚀 Features

### Core Features
- ✅ **Automated DCA Plans** - Set it and forget it
- ✅ **Flexible Time Cycles** - Hourly or daily executions
- ✅ **Multiple Executions Scheduling** - Schedule all executions upfront
- ✅ **Resource-Based Ownership** - Plans stored in user accounts
- ✅ **Pause/Resume** - Temporarily pause plans
- ✅ **Max Executions** - Set limits or run indefinitely

### Frontend Features
- ✅ **Flow Wallet Integration** - Connect with Flow wallet
- ✅ **Dashboard** - View all plans and stats
- ✅ **Execution History** - Track all past executions
- ✅ **Real-time Updates** - Live blockchain data
- ✅ **Test Token Faucet** - Claim test USD for testing

### Telegram Bot
- ✅ **Wallet Linking** - Link Flow wallet to Telegram
- ✅ **Real-time Notifications** - Get alerts when plans execute
- ✅ **Plan Monitoring** - Check plans from Telegram
- ✅ **Balance Checking** - View FLOW, USD, BTC balances
- ✅ **Execution History** - View history from Telegram

### Technical Features
- ✅ **Scheduled Transactions** - Native Flow automation
- ✅ **Resource-Oriented** - Cadence's safety guarantees
- ✅ **Capability-Based Access** - Fine-grained permissions
- ✅ **Event-Driven** - Comprehensive event logging
- ✅ **Mock DEX** - Simulated exchange for testing

## 📁 Project Structure

```
dca-btc-flow/
├── dca/                                       # Cadence smart contracts
│   ├── cadence/
│   │   ├── contracts/
│   │   │   ├── DCAContract.cdc                # Main DCA contract
│   │   │   ├── DCATransactionHandler.cdc      # Scheduled transaction handler
│   │   │   ├── MockUSD.cdc                    # Test USD token
│   │   │   ├── MockBTC.cdc                    # Test BTC token
│   │   │   └── SimpleSwap.cdc                 # Mock DEX for testing
│   │   ├── transactions/
│   │   │   ├── SetupAccount.cdc               # Initialize user account
│   │   │   ├── SetupDCAHandler.cdc            # Setup scheduler
│   │   │   ├── CreateDCAPlan.cdc              # Create new plan
│   │   │   ├── ScheduleMultipleDCAExecutions.cdc  # Schedule executions
│   │   │   ├── StopPlan.cdc                   # Stop plan
│   │   │   ├── PausePlan.cdc                  # Pause plan
│   │   │   ├── ResumePlan.cdc                 # Resume plan
│   │   │   └── MintTestTokens.cdc             # Mint test tokens
│   │   └── scripts/
│   │       ├── GetUserPlans.cdc               # Query user's plans
│   │       ├── GetPlanDetails.cdc             # Query plan details
│   │       └── CheckAccountSetup.cdc          # Check if account is setup
│   └── flow.json                              # Flow configuration
├── front-end/                                 # React frontend
│   ├── src/
│   │   ├── components/                        # UI components
│   │   ├── hooks/
│   │   │   └── useFlow.ts                     # Flow blockchain hooks
│   │   ├── lib/
│   │   │   └── flow-config.ts                 # FCL configuration
│   │   └── pages/
│   │       └── Index.tsx                      # Main page
│   └── package.json
├── scripts/
│   ├── telegram-bot.js                        # Telegram notification bot
│   └── TELEGRAM_BOT_README.md                 # Telegram bot guide
├── DEMO_SCRIPT.md                             # Demo walkthrough script
└── README_FLOW.md                             # This file
```

## 🏃 Quick Start

### Prerequisites

- Node.js 16+ installed
- Flow wallet extension installed ([Chrome](https://chrome.google.com/webstore/detail/flow-wallet/hpclkefagolihohboafpheddmmgdffjm))

### 1. Clone and Install

```bash
git clone <repository-url>
cd dca-btc-flow
npm install
```

### 2. Start Frontend

```bash
cd front-end
npm install
npm run dev
```

The app will be available at `http://localhost:8080`

### 3. Connect Wallet

1. Open `http://localhost:8080` in your browser
2. Click "Connect Wallet"
3. Approve the connection in Flow wallet

### 4. Setup Account

1. Click "Setup Account" button
2. Approve the transaction
3. Wait for confirmation

### 5. Setup Scheduler

1. Click "Setup Scheduler" button
2. Approve the transaction
3. Wait for confirmation

### 6. Get Test Tokens

1. Click "Get FLOW from Faucet" to get FLOW tokens for gas
2. Click "Claim Test USD" to get 1000 test USD

### 7. Create DCA Plan

1. Click "Create New Plan"
2. Fill in the form:
   - Amount per execution: `10` USD
   - Time between executions: `1` hour
   - Maximum executions: `5`
3. Click "Create Plan"
4. Approve the transaction

### 8. Schedule Executions

1. Find your plan card
2. Click "Schedule Executions"
3. Enter number of executions: `5`
4. Click "Schedule"
5. Approve the transaction

### 9. Watch It Run!

Your DCA plan will now execute automatically every hour. Check the "Execution History" section to see completed executions.

For a detailed demo walkthrough, see **[DEMO_SCRIPT.md](DEMO_SCRIPT.md)**

## 📱 Telegram Bot (Optional)

Get real-time notifications when your DCA plans execute!

### Setup

1. Create a Telegram bot via [@BotFather](https://t.me/botfather)
2. Copy your bot token
3. Create `.env` file:
   ```bash
   TELEGRAM_BOT_TOKEN=your_bot_token_here
   ```
4. Install dependencies and run:
   ```bash
   npm install
   npm run telegram
   ```
5. Link your wallet in Telegram:
   ```
   /start YOUR_FLOW_ADDRESS
   ```

### Commands

- `/wallet` - View balances
- `/plans` - View DCA plans
- `/history` - View execution history
- `/help` - Show all commands

See **[scripts/TELEGRAM_BOT_README.md](scripts/TELEGRAM_BOT_README.md)** for detailed guide.

## 📚 How It Works

### Traditional DCA (EVM)

```
User → Creates Plan → Stored in Contract
                           ↓
                    Keeper Bot Monitors
                           ↓
                    Keeper Executes Swap
                           ↓
                    Repeat Forever
```

**Problems:**
- Requires keeper bot infrastructure
- Centralized execution
- Single point of failure
- Ongoing maintenance costs

### Flow DCA (This Project)

```
User → Creates Plan → Stored in User's Account
                           ↓
                    Schedules Multiple Executions
                           ↓
                    Network Executes Automatically
                           ↓
                    Repeat Until All Scheduled
```

**Benefits:**
- No keeper bot needed
- Fully decentralized
- Network guaranteed
- No maintenance costs
- Schedule all executions upfront

### Execution Flow

1. **User creates DCA plan** - Specifies amount, interval, max executions
2. **User schedules executions** - Pays FLOW fees upfront for all executions
3. **Blockchain executes automatically** - At each scheduled time:
   - Withdraws USD from user's plan
   - Swaps USD for BTC via SimpleSwap
   - Deposits BTC to user's account
   - Emits execution event
4. **Telegram bot notifies** - User gets real-time notification
5. **History updates** - Execution appears in dashboard

## 🎯 Key Concepts

### Resources

Resources are Cadence's way of representing ownership:

```cadence
// Create a resource
let plan <- create DCAplan(...)

// Move it (can only exist in one place)
self.plans[planId] <-! plan

// Destroy it
destroy plan
```

### Capabilities

Capabilities provide fine-grained access control:

```cadence
// Create a capability
let cap = account.capabilities.storage
    .issue<&PlanManager>(storagePath)

// Publish it
account.capabilities.publish(cap, at: publicPath)
```

### Scheduled Transactions

Flow's killer feature:

```cadence
// Schedule execution
manager.schedule(
    handlerCap: handlerCap,
    data: executionData,
    timestamp: futureTime,
    priority: .Medium,
    executionEffort: 1000,
    fees: <-feeVault
)

// Network executes automatically at timestamp!
```

## 🛠️ Development

### Smart Contracts

All contracts are in `dca/cadence/contracts/`:

- **DCAContract.cdc** - Main DCA logic, plan management
- **DCATransactionHandler.cdc** - Handles scheduled executions
- **MockUSD.cdc** - Test USD token (FungibleToken)
- **MockBTC.cdc** - Test BTC token (FungibleToken)
- **SimpleSwap.cdc** - Mock DEX for testing

### Frontend

Built with React + TypeScript + Vite:

- **FCL Integration** - Flow Client Library for blockchain interaction
- **shadcn/ui** - Modern UI components
- **TailwindCSS** - Styling
- **React Query** - Data fetching

Key files:
- `front-end/src/hooks/useFlow.ts` - All blockchain interaction hooks
- `front-end/src/lib/flow-config.ts` - FCL configuration
- `front-end/src/components/` - UI components

### Testing on Testnet

The contracts are already deployed on Flow Testnet at `0x78acd984694957cf`. You can:

1. Use the frontend at `http://localhost:8080`
2. Connect your Flow wallet
3. Test with real testnet transactions
4. View on Flowscan: https://testnet.flowscan.io

### Local Development

```bash
# Frontend
cd front-end
npm run dev

# Telegram Bot
npm run telegram
```

## 📖 Documentation

### Project Documentation
- **[DEMO_SCRIPT.md](DEMO_SCRIPT.md)** - Complete demo walkthrough
- **[scripts/TELEGRAM_BOT_README.md](scripts/TELEGRAM_BOT_README.md)** - Telegram bot guide

### Flow Resources
- **[Flow Developer Portal](https://developers.flow.com/)** - Official Flow docs
- **[Cadence Language](https://cadence-lang.org/)** - Cadence documentation
- **[Flow Client Library (FCL)](https://developers.flow.com/tools/clients/fcl-js)** - JavaScript SDK
- **[FungibleToken Standard](https://github.com/onflow/flow-ft)** - Token standard

### Deployed Contracts
- **DCAContract**: [0x78acd984694957cf](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCAContract)
- **DCATransactionHandler**: [0x78acd984694957cf](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCATransactionHandler)
- **MockUSD**: [0x78acd984694957cf](https://testnet.flowscan.io/contract/A.78acd984694957cf.MockUSD)
- **MockBTC**: [0x78acd984694957cf](https://testnet.flowscan.io/contract/A.78acd984694957cf.MockBTC)

## 🎯 Key Features Explained

### Scheduled Transactions

Flow's killer feature that makes this DCA protocol possible:

```cadence
// User schedules execution
let scheduledTxManager = getAccount(schedulerAddress)
    .capabilities.get<&ScheduledTransactionManager>(
        ScheduledTransactionManager.ManagerPublicPath
    )!.borrow()!

scheduledTxManager.schedule(
    handlerCap: handlerCap,
    data: executionData,
    timestamp: futureTime,
    priority: .Medium,
    executionEffort: 1000,
    fees: <-feeVault
)
```

The blockchain will automatically execute this at `futureTime` - no external trigger needed!

### Resource-Oriented Programming

Plans are resources owned by users:

```cadence
// Create a plan (resource)
let plan <- create DCAplan(...)

// Store in user's account
self.plans[planId] <-! plan

// Only the owner can access it
```

This ensures:
- Plans can't be duplicated
- Only owner can modify
- Automatic cleanup on deletion

### Multiple Execution Scheduling

Instead of scheduling one execution at a time, users can schedule all executions upfront:

```cadence
// Schedule 5 executions at once
for i in 0..<5 {
    let executionTime = currentTime + (interval * UFix64(i + 1))
    // Schedule execution at executionTime
}
```

Benefits:
- Pay all fees upfront
- True "set it and forget it"
- No need to come back

## 🤝 Community

- **Discord:** https://discord.gg/flow
- **Forum:** https://forum.flow.com/
- **Flow Testnet Faucet:** https://testnet-faucet.onflow.org/

## 📝 License

MIT License

## 🚀 Roadmap

### ✅ Completed
- [x] Smart contracts deployed on testnet
- [x] Frontend with Flow wallet integration
- [x] Telegram bot for notifications
- [x] Multiple execution scheduling
- [x] Execution history tracking
- [x] Test token faucets

### 🔜 Future Enhancements
- [ ] Integration with real DEX (IncrementFi, BloctoSwap)
- [ ] Support for real stablecoins (USDC)
- [ ] Support for more trading pairs
- [ ] Advanced DCA strategies (buy the dip, etc.)
- [ ] Mobile app
- [ ] Mainnet deployment

## 🙏 Acknowledgments

- Flow team for Scheduled Transactions feature
- Flow community for support and feedback
- Cadence language for making smart contracts safer

---

**Built with ❤️ on Flow Blockchain**

**Live on Flow Testnet** | **Contract: 0x78acd984694957cf** | **[View on Flowscan](https://testnet.flowscan.io/contract/A.78acd984694957cf.DCAContract)**

