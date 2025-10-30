import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { useFlowUser, useTokenBalances, useUserPlans } from '@/hooks/useFlow';
import { Wallet, TrendingUp, Clock } from 'lucide-react';

export const DashboardStats = () => {
  const user = useFlowUser();
  const { balances } = useTokenBalances(user.addr);
  const { plans } = useUserPlans(user.addr);

  const activePlans = plans?.length || 0;

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <Card className="glass-card border border-border/30 hover-glow-primary">
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
          <CardTitle className="text-sm font-medium tracking-wide text-foreground/80">USD Balance</CardTitle>
          <div className="w-10 h-10 rounded-xl bg-accent/10 flex items-center justify-center glow-accent-sm">
            <Wallet className="h-5 w-5 text-accent" />
          </div>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold gradient-text tracking-tight">
            {parseFloat(balances.USD || '0').toFixed(2)}
          </div>
          <p className="text-xs text-foreground/50 mt-2 tracking-wide">Available for DCA</p>
        </CardContent>
      </Card>

      <Card className="glass-card border border-border/30 hover-glow-primary">
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
          <CardTitle className="text-sm font-medium tracking-wide text-foreground/80">BTC Balance</CardTitle>
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center glow-primary-sm">
            <TrendingUp className="h-5 w-5 text-primary" />
          </div>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold gradient-text tracking-tight">
            {parseFloat(balances.BTC || '0').toFixed(6)}
          </div>
          <p className="text-xs text-foreground/50 mt-2 tracking-wide">Accumulated</p>
        </CardContent>
      </Card>

      <Card className="glass-card border border-border/30 hover-glow-primary">
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
          <CardTitle className="text-sm font-medium tracking-wide text-foreground/80">Active Plans</CardTitle>
          <div className="w-10 h-10 rounded-xl bg-accent/10 flex items-center justify-center glow-accent-sm">
            <Clock className="h-5 w-5 text-accent" />
          </div>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold gradient-text tracking-tight">{activePlans}</div>
          <p className="text-xs text-foreground/50 mt-2 tracking-wide">Running strategies</p>
        </CardContent>
      </Card>
    </div>
  );
};
