import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { History, ExternalLink, TrendingUp, Coins } from 'lucide-react';
import { useFlowUser, useExecutionHistory } from '@/hooks/useFlow';
import { Badge } from '@/components/ui/badge';

export function ExecutionHistory() {
  const user = useFlowUser();
  const { executions, loading } = useExecutionHistory(user.addr);

  return (
    <Card className="glass-card border border-border/30">
      <CardHeader>
        <CardTitle className="flex items-center gap-3 tracking-tight">
          <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center glow-primary-sm">
            <History className="w-5 h-5 text-primary" />
          </div>
          Execution History
        </CardTitle>
        <CardDescription className="text-foreground/60 tracking-wide">
          {executions.length > 0
            ? `${executions.length} execution${executions.length === 1 ? '' : 's'} completed`
            : 'No executions yet'}
        </CardDescription>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="p-8 text-center">
            <p className="text-sm text-foreground/60">Loading execution history...</p>
          </div>
        ) : executions.length === 0 ? (
          <div className="p-8 text-center">
            <p className="text-sm text-foreground/60 mb-4">
              No executions yet. Schedule your first execution to see it here!
            </p>
            <a
              href="https://testnet.flowscan.io/contract/A.78acd984694957cf.DCAContract"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:underline text-sm inline-flex items-center gap-1"
            >
              View Contract on Flowscan <ExternalLink className="w-3 h-3" />
            </a>
          </div>
        ) : (
          <div className="space-y-3">
            {executions.map((execution, index) => {
              const amountIn = parseFloat(execution.amountIn).toFixed(2);
              const amountOut = parseFloat(execution.amountOut).toFixed(6);
              const price = (parseFloat(execution.amountIn) / parseFloat(execution.amountOut)).toFixed(2);

              return (
                <div
                  key={`${execution.transactionId}-${index}`}
                  className="p-4 rounded-xl border border-border/40 bg-secondary/20 hover:bg-secondary/30 transition-colors"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <Badge variant="outline" className="text-xs">
                        Plan #{execution.planId}
                      </Badge>
                      <Badge variant="secondary" className="text-xs">
                        Execution #{execution.executionNumber}
                      </Badge>
                    </div>
                    <a
                      href={`https://testnet.flowscan.io/transaction/${execution.transactionId}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary hover:underline text-xs inline-flex items-center gap-1"
                    >
                      View Tx <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>

                  <div className="grid grid-cols-3 gap-4 text-sm">
                    <div>
                      <div className="flex items-center text-foreground/60 text-xs mb-1">
                        <TrendingUp className="w-3 h-3 mr-1" />
                        USD Spent
                      </div>
                      <div className="font-semibold">{amountIn}</div>
                    </div>
                    <div>
                      <div className="flex items-center text-foreground/60 text-xs mb-1">
                        <Coins className="w-3 h-3 mr-1" />
                        BTC Received
                      </div>
                      <div className="font-semibold">{amountOut}</div>
                    </div>
                    <div>
                      <div className="text-foreground/60 text-xs mb-1">
                        Price
                      </div>
                      <div className="font-semibold">{price} USD/BTC</div>
                    </div>
                  </div>

                  <div className="mt-2 text-xs text-foreground/50">
                    Block #{execution.blockHeight}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

