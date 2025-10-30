import { useState } from 'react';
import { WalletButton } from '@/components/WalletButton';
import { CreatePlanModal } from '@/components/CreatePlanModal';
import { PlanCard } from '@/components/PlanCard';
import { DashboardStats } from '@/components/DashboardStats';
import { ExecutionHistory } from '@/components/ExecutionHistory';
import { TelegramLink } from '@/components/TelegramLink';
import { Button } from '@/components/ui/button';
import { useFlowUser, useUserPlans, useAccountSetup, mintTestTokens, setupAccount, setupDCAHandler } from '@/hooks/useFlow';
import { TrendingUp, Zap, Gift, Settings, AlertCircle, Clock } from 'lucide-react';
import { toast } from 'sonner';

const Index = () => {
  const user = useFlowUser();
  const { isSetup } = useAccountSetup(user.addr);
  const { plans: planIds } = useUserPlans(user.addr);
  const [isMinting, setIsMinting] = useState(false);
  const [isSettingUp, setIsSettingUp] = useState(false);
  const [isSettingUpScheduler, setIsSettingUpScheduler] = useState(false);

  const handleSetupAccount = async () => {
    setIsSettingUp(true);
    try {
      await setupAccount();
      toast.success('Account setup complete! You can now create DCA plans.');
      // Refresh the page to update the setup status
      window.location.reload();
    } catch (error: any) {
      console.error('Setup error:', error);
      toast.error(error.message || 'Failed to setup account');
    } finally {
      setIsSettingUp(false);
    }
  };

  const handleSetupScheduler = async () => {
    setIsSettingUpScheduler(true);
    try {
      await setupDCAHandler();
      toast.success('Scheduler setup complete! You can now schedule executions.');
    } catch (error: any) {
      console.error('Scheduler setup error:', error);
      toast.error(error.message || 'Failed to setup scheduler');
    } finally {
      setIsSettingUpScheduler(false);
    }
  };

  const handleMintTokens = async () => {
    setIsMinting(true);
    try {
      await mintTestTokens("1000.0", "0.0");
      toast.success('Successfully minted 1000 test USD!');
    } catch (error: any) {
      console.error('Mint error:', error);
      toast.error(error.message || 'Failed to mint tokens');
    } finally {
      setIsMinting(false);
    }
  };

  return (
    <div className="min-h-screen">
      {/* Header - Futuristic with subtle glow */}
      <header className="border-b border-border/40 backdrop-blur-xl sticky top-0 z-50 glass-card-strong">
        <div className="container mx-auto px-6 py-5">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-2xl gradient-bg-primary flex items-center justify-center glow-primary-sm animate-glow">
                <Zap className="w-7 h-7 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold gradient-text tracking-tight">DCA Protocol</h1>
                <p className="text-xs text-muted-foreground tracking-wide">Automated Dollar Cost Averaging</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              {user.loggedIn && (
                <>
                  <Button
                    onClick={handleSetupAccount}
                    disabled={isSettingUp}
                    variant="outline"
                    size="sm"
                    className="gap-2"
                  >
                    <Settings className="w-4 h-4" />
                    {isSettingUp ? 'Setting up...' : 'Setup Account'}
                  </Button>
                  <Button
                    onClick={handleSetupScheduler}
                    disabled={isSettingUpScheduler}
                    variant="outline"
                    size="sm"
                    className="gap-2"
                  >
                    <Clock className="w-4 h-4" />
                    {isSettingUpScheduler ? 'Setting up...' : 'Setup Scheduler'}
                  </Button>
                  <Button
                    onClick={handleMintTokens}
                    disabled={isMinting}
                    variant="outline"
                    size="sm"
                    className="gap-2"
                  >
                    <Gift className="w-4 h-4" />
                    {isMinting ? 'Minting...' : 'Claim 1000 USD'}
                  </Button>
                </>
              )}
              <WalletButton />
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-6 py-12">
        {!user.loggedIn ? (
          <div className="flex flex-col items-center justify-center min-h-[70vh] text-center">
            <div className="w-24 h-24 rounded-3xl gradient-bg-primary flex items-center justify-center glow-primary mb-8 animate-glow">
              <TrendingUp className="w-12 h-12 text-white" />
            </div>
            <h2 className="text-5xl font-bold mb-6 gradient-text tracking-tight">
              Welcome to DCA Protocol
            </h2>
            <p className="text-xl text-foreground/70 mb-10 max-w-2xl leading-relaxed">
              Automate your cryptocurrency purchases with Dollar Cost Averaging on Flow blockchain.
              Set up recurring swaps from USD to BTC at your preferred intervals using native scheduled transactions.
            </p>
            <WalletButton />
          </div>
        ) : (
          <div className="space-y-10">
            {/* Setup Banner - Show if account is not setup */}
            {isSetup === false && (
              <div className="glass-card rounded-2xl p-8 border-2 border-primary/50 bg-primary/5">
                <div className="flex items-start gap-6">
                  <div className="w-16 h-16 rounded-2xl bg-primary/20 flex items-center justify-center flex-shrink-0">
                    <AlertCircle className="w-8 h-8 text-primary" />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-2xl font-bold mb-3 gradient-text">Account Setup Required</h3>
                    <p className="text-foreground/70 mb-4 leading-relaxed">
                      Before you can create DCA plans, you need to initialize your account with the DCA Protocol.
                      This is a one-time setup that creates the necessary resources in your Flow account.
                    </p>
                    <div className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4 mb-6">
                      <p className="text-sm text-yellow-200/90 mb-2">
                        ⚠️ <strong>Need FLOW tokens?</strong> You need testnet FLOW to pay for transactions.
                      </p>
                      <a
                        href="https://testnet-faucet.onflow.org/"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-sm text-primary hover:underline"
                      >
                        → Get free testnet FLOW from the faucet
                      </a>
                    </div>
                    <div className="flex flex-wrap gap-3">
                      <Button
                        onClick={handleSetupAccount}
                        disabled={isSettingUp}
                        size="lg"
                        className="gap-2"
                      >
                        <Settings className="w-5 h-5" />
                        {isSettingUp ? 'Setting up...' : '1. Setup Account'}
                      </Button>
                      <Button
                        onClick={handleSetupScheduler}
                        disabled={isSettingUpScheduler}
                        size="lg"
                        variant="outline"
                        className="gap-2"
                      >
                        <Clock className="w-5 h-5" />
                        {isSettingUpScheduler ? 'Setting up...' : '2. Setup Scheduler'}
                      </Button>
                      <Button
                        onClick={handleMintTokens}
                        disabled={isMinting}
                        variant="outline"
                        size="lg"
                        className="gap-2"
                      >
                        <Gift className="w-5 h-5" />
                        {isMinting ? 'Minting...' : '3. Claim 1000 USD'}
                      </Button>
                    </div>
                    <p className="text-xs text-foreground/50 mt-4">
                      💡 Click buttons in order for best results!
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Stats */}
            <DashboardStats />

            {/* Plans Section */}
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-3xl font-bold tracking-tight">Your DCA Plans</h2>
                  <p className="text-foreground/60 mt-1 tracking-wide">
                    Manage your automated trading strategies
                  </p>
                </div>
                <CreatePlanModal />
              </div>

              {planIds && planIds.length > 0 ? (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {planIds.map((planId) => (
                    <PlanCard key={planId.toString()} planId={planId} />
                  ))}
                </div>
              ) : (
                <div className="glass-card rounded-2xl p-16 text-center border border-border/30">
                  <div className="w-20 h-20 rounded-2xl bg-secondary/50 flex items-center justify-center mx-auto mb-6 glow-primary-sm">
                    <TrendingUp className="w-10 h-10 text-primary" />
                  </div>
                  <h3 className="text-2xl font-semibold mb-3 tracking-tight">No DCA plans yet</h3>
                  <p className="text-foreground/60 mb-8 max-w-md mx-auto">
                    Create your first automated trading plan to get started
                  </p>
                  <CreatePlanModal />
                </div>
              )}
            </div>

            {/* Execution History and Telegram */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div className="lg:col-span-2">
                <ExecutionHistory />
              </div>
              <div>
                <TelegramLink />
              </div>
            </div>

            {/* Info Cards - Premium feel with geometric precision */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-10">
              <div className="glass-card rounded-2xl p-8 border border-border/30 hover-glow-primary">
                <h3 className="text-xl font-semibold mb-5 gradient-text tracking-tight">How it works</h3>
                <ul className="space-y-3 text-sm text-foreground/70 leading-relaxed">
                  <li className="flex items-start gap-3">
                    <span className="text-primary mt-0.5">▸</span>
                    <span>Create a plan with your desired swap amount and interval</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-primary mt-0.5">▸</span>
                    <span>Deposit USD tokens into your plan</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-primary mt-0.5">▸</span>
                    <span>Schedule executions using Flow's native scheduler</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-primary mt-0.5">▸</span>
                    <span>Receive BTC directly to your wallet</span>
                  </li>
                </ul>
              </div>

              <div className="glass-card rounded-2xl p-8 border border-border/30 hover-glow-accent bg-accent/5">
                <h3 className="text-xl font-semibold mb-5 gradient-text tracking-tight">Get Testnet FLOW</h3>
                <p className="text-sm text-foreground/70 mb-4 leading-relaxed">
                  To schedule executions, you need FLOW tokens to pay transaction fees. Get free testnet FLOW:
                </p>
                <a
                  href="https://testnet-faucet.onflow.org"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 px-4 py-2 bg-primary/20 hover:bg-primary/30 text-primary rounded-lg transition-colors text-sm font-medium"
                >
                  <Gift className="w-4 h-4" />
                  Get Free FLOW Tokens
                </a>
                <p className="text-xs text-foreground/50 mt-4">
                  You'll need ~0.002 FLOW per scheduled execution
                </p>
              </div>

              <div className="glass-card rounded-2xl p-8 border border-border/30 hover-glow-primary">
                <h3 className="text-xl font-semibold mb-5 gradient-text tracking-tight">Benefits</h3>
                <ul className="space-y-3 text-sm text-foreground/70 leading-relaxed">
                  <li className="flex items-start gap-3">
                    <span className="text-accent mt-0.5">▸</span>
                    <span>Reduce timing risk with consistent purchases</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-accent mt-0.5">▸</span>
                    <span>Remove emotion from your investment strategy</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-accent mt-0.5">▸</span>
                    <span>Fully automated - set it and forget it</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <span className="text-accent mt-0.5">▸</span>
                    <span>Stop or adjust plans anytime</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
};

export default Index;
