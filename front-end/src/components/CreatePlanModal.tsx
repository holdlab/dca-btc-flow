import { useState } from 'react';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { useFlowUser, createDCAPlan } from '@/hooks/useFlow';
import { toast } from 'sonner';
import { Plus } from 'lucide-react';

export const CreatePlanModal = () => {
  const [open, setOpen] = useState(false);
  const [amount, setAmount] = useState('');
  const [totalAmount, setTotalAmount] = useState('');
  const [interval, setInterval] = useState<'minute' | 'hourly' | 'daily'>('hourly');
  const [isProcessing, setIsProcessing] = useState(false);
  const user = useFlowUser();

  const handleCreatePlan = async () => {
    if (!amount || !totalAmount || !user.loggedIn) return;

    setIsProcessing(true);
    try {
      const timeCycleMap = {
        'minute': '60.0',
        'hourly': '3600.0',
        'daily': '86400.0',
      };

      await createDCAPlan(
        amount,
        timeCycleMap[interval],
        totalAmount
      );

      toast.success('DCA Plan created successfully!');
      setOpen(false);
      setAmount('');
      setTotalAmount('');
    } catch (error: any) {
      console.error('Create plan error:', error);
      const errorMessage = error.message || 'Failed to create plan';

      if (errorMessage.includes('Could not borrow PlanManager')) {
        toast.error('Please setup your account first! Click "Setup Account" button in the header.');
      } else {
        toast.error(errorMessage);
      }
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button className="bg-gradient-to-r from-primary to-accent hover:opacity-90 text-white border-0 glow-primary">
          <Plus className="w-4 h-4 mr-2" />
          Create DCA Plan
        </Button>
      </DialogTrigger>
      <DialogContent className="glass-card border-border">
        <DialogHeader>
          <DialogTitle className="text-2xl gradient-text">Create DCA Plan</DialogTitle>
          <DialogDescription>
            Set up automated swaps from USD to BTC at regular intervals on Flow
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          <div className="space-y-2">
            <Label htmlFor="amount">Amount per swap (USD)</Label>
            <Input
              id="amount"
              type="number"
              placeholder="10.0"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              className="glass-card"
            />
            <p className="text-xs text-muted-foreground">
              Amount to swap each execution
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="totalAmount">Total deposit (USD)</Label>
            <Input
              id="totalAmount"
              type="number"
              placeholder="100.0"
              value={totalAmount}
              onChange={(e) => setTotalAmount(e.target.value)}
              className="glass-card"
            />
            <p className="text-xs text-muted-foreground">
              Total USD to deposit into the plan
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="interval">Swap Interval</Label>
            <Select value={interval} onValueChange={(v: 'minute' | 'hourly' | 'daily') => setInterval(v)}>
              <SelectTrigger className="glass-card">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="glass-card border-border">
                <SelectItem value="minute">Every Minute (Testing)</SelectItem>
                <SelectItem value="hourly">Every Hour</SelectItem>
                <SelectItem value="daily">Every Day</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="p-4 bg-secondary/30 rounded-xl border border-border/40">
            <p className="text-xs text-foreground/60 leading-relaxed">
              💡 After creating the plan, you'll need to schedule executions using Flow's native scheduler.
              Each execution requires a small FLOW fee (~0.001 FLOW).
            </p>
          </div>

          <Button
            onClick={handleCreatePlan}
            disabled={!amount || !totalAmount || !user.loggedIn || isProcessing}
            className="w-full bg-gradient-to-r from-primary to-accent hover:opacity-90 text-white border-0"
          >
            {isProcessing ? 'Creating...' : 'Create Plan'}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
};
