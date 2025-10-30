import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { useFlowUser, usePlanDetails, stopPlan, pausePlan, resumePlan, scheduleExecution, scheduleMultipleExecutions } from '@/hooks/useFlow';
import { toast } from 'sonner';
import { Square, Clock, TrendingUp, Calendar, Pause, Play, Zap } from 'lucide-react';

interface PlanCardProps {
  planId: number;
}

export const PlanCard = ({ planId }: PlanCardProps) => {
  const user = useFlowUser();
  const { plan, loading } = usePlanDetails(user.addr, planId);
  const [isProcessing, setIsProcessing] = useState(false);
  const [isScheduleDialogOpen, setIsScheduleDialogOpen] = useState(false);
  const [numberOfExecutions, setNumberOfExecutions] = useState('5');

  if (loading || !plan) return null;

  const handleStop = async () => {
    setIsProcessing(true);
    try {
      await stopPlan(planId);
      toast.success('Plan stopped successfully!');
    } catch (error: any) {
      console.error('Stop error:', error);
      toast.error(error.message || 'Failed to stop plan');
    } finally {
      setIsProcessing(false);
    }
  };

  const handlePause = async () => {
    setIsProcessing(true);
    try {
      await pausePlan(planId);
      toast.success('Plan paused successfully!');
    } catch (error: any) {
      console.error('Pause error:', error);
      toast.error(error.message || 'Failed to pause plan');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleResume = async () => {
    setIsProcessing(true);
    try {
      await resumePlan(planId);
      toast.success('Plan resumed successfully!');
    } catch (error: any) {
      console.error('Resume error:', error);
      toast.error(error.message || 'Failed to resume plan');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleScheduleMultiple = async () => {
    const count = parseInt(numberOfExecutions);
    if (isNaN(count) || count < 1 || count > 100) {
      toast.error('Please enter a number between 1 and 100');
      return;
    }

    setIsProcessing(true);
    try {
      // Convert timeCycle from UFix64 string to seconds
      const intervalSeconds = parseFloat(plan.timeCycle);

      await scheduleMultipleExecutions(planId, count, intervalSeconds, 1, 1000);
      toast.success(`Successfully scheduled ${count} executions!`);
      setIsScheduleDialogOpen(false);
    } catch (error: any) {
      console.error('Schedule error:', error);
      const errorMessage = error.message || 'Failed to schedule executions';

      if (errorMessage.includes('Could not borrow Manager')) {
        toast.error('Please setup the scheduler first! Click "Setup Scheduler" button in the header.', {
          duration: 8000,
        });
      } else if (errorMessage.includes('Cannot withdraw tokens') || errorMessage.includes('greater than the balance')) {
        toast.error('Not enough FLOW tokens! Get free testnet FLOW from: https://testnet-faucet.onflow.org', {
          duration: 10000,
        });
      } else {
        toast.error(errorMessage);
      }
    } finally {
      setIsProcessing(false);
    }
  };

  const formatTime = (timestamp: string) => {
    if (!timestamp || timestamp === '0.00000000') return 'Not yet';
    const date = new Date(parseFloat(timestamp) * 1000);
    return date.toLocaleString();
  };

  const getInterval = (timeCycle: string) => {
    const seconds = parseFloat(timeCycle);
    if (seconds === 60) return '1 minute';
    if (seconds === 3600) return '1 hour';
    if (seconds === 86400) return '1 day';
    return `${seconds}s`;
  };

  const interval = getInterval(plan.timeCycle);
  const amount = parseFloat(plan.amountPerExecution).toFixed(2);

  const getStatusBadge = () => {
    if (!plan.isActive) return { text: 'Stopped', variant: 'secondary' as const };
    if (plan.isPaused) return { text: 'Paused', variant: 'outline' as const };
    return { text: 'Active', variant: 'default' as const };
  };

  const status = getStatusBadge();

  return (
    <Card className="glass-card border border-border/30 hover-glow-primary transition-all duration-300">
      <CardHeader className="pb-4">
        <div className="flex items-center justify-between">
          <CardTitle className="text-xl tracking-tight">Plan #{planId}</CardTitle>
          <Badge
            variant={status.variant}
            className={plan.isActive && !plan.isPaused ? "bg-success glow-primary-sm" : ""}
          >
            {status.text}
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-5">
        <div className="grid grid-cols-2 gap-5 text-sm">
          <div className="space-y-2">
            <div className="flex items-center text-foreground/60 tracking-wide">
              <TrendingUp className="w-4 h-4 mr-2 text-primary" />
              Amount
            </div>
            <div className="font-semibold text-foreground tracking-tight">{amount} USD</div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center text-foreground/60 tracking-wide">
              <Clock className="w-4 h-4 mr-2 text-accent" />
              Interval
            </div>
            <div className="font-semibold text-foreground tracking-tight">{interval}</div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center text-foreground/60 tracking-wide">
              <Calendar className="w-4 h-4 mr-2 text-primary" />
              Executions
            </div>
            <div className="font-semibold text-foreground tracking-tight">
              {plan.totalExecutions}
            </div>
          </div>

          <div className="space-y-2">
            <div className="text-foreground/60 text-xs tracking-wide">Balance</div>
            <div className="font-semibold text-xs text-foreground tracking-tight">
              {parseFloat(plan.balance).toFixed(2)} USD
            </div>
          </div>

          <div className="space-y-2 col-span-2">
            <div className="text-foreground/60 text-xs tracking-wide">Last Execution</div>
            <div className="font-semibold text-xs text-foreground tracking-tight">
              {formatTime(plan.lastExecution)}
            </div>
          </div>
        </div>

        <div className="p-4 bg-secondary/30 rounded-xl border border-border/40 backdrop-blur-sm">
          <p className="text-xs text-foreground/60 text-center tracking-wide leading-relaxed">
            ⚡ Plans use Flow's native scheduled transactions for automatic execution
          </p>
        </div>

        <div className="flex gap-2">
          {plan.isActive && !plan.isPaused && (
            <>
              <Dialog open={isScheduleDialogOpen} onOpenChange={setIsScheduleDialogOpen}>
                <DialogTrigger asChild>
                  <Button
                    variant="default"
                    size="sm"
                    className="flex-1 rounded-xl"
                    disabled={isProcessing}
                  >
                    <Zap className="w-4 h-4 mr-2" />
                    Schedule
                  </Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Schedule Executions</DialogTitle>
                    <DialogDescription>
                      How many executions would you like to schedule? Each execution will happen at the plan's interval ({plan.timeCycle}s).
                    </DialogDescription>
                  </DialogHeader>
                  <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                      <Label htmlFor="executions">Number of Executions</Label>
                      <Input
                        id="executions"
                        type="number"
                        min="1"
                        max="100"
                        value={numberOfExecutions}
                        onChange={(e) => setNumberOfExecutions(e.target.value)}
                        placeholder="e.g., 5"
                      />
                      <p className="text-xs text-muted-foreground">
                        💡 You'll need ~0.002 FLOW per execution. For {numberOfExecutions} executions, you'll need ~{(parseFloat(numberOfExecutions) * 0.002).toFixed(3)} FLOW.
                      </p>
                    </div>
                  </div>
                  <DialogFooter>
                    <Button
                      onClick={handleScheduleMultiple}
                      disabled={isProcessing}
                    >
                      {isProcessing ? 'Scheduling...' : `Schedule ${numberOfExecutions} Executions`}
                    </Button>
                  </DialogFooter>
                </DialogContent>
              </Dialog>
              <Button
                onClick={handlePause}
                variant="outline"
                size="sm"
                className="flex-1 rounded-xl"
                disabled={isProcessing}
              >
                <Pause className="w-4 h-4 mr-2" />
                Pause
              </Button>
            </>
          )}

          {plan.isActive && plan.isPaused && (
            <Button
              onClick={handleResume}
              variant="default"
              size="sm"
              className="flex-1 rounded-xl"
              disabled={isProcessing}
            >
              <Play className="w-4 h-4 mr-2" />
              Resume
            </Button>
          )}

          {plan.isActive && (
            <Button
              onClick={handleStop}
              variant="destructive"
              size="sm"
              className="flex-1 rounded-xl"
              disabled={isProcessing}
            >
              <Square className="w-4 h-4 mr-2" />
              Stop
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
