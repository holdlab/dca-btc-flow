import { useState, useEffect } from 'react';
import { fcl } from '@/lib/flow-config';
import { Button } from './ui/button';

export const WalletButton = () => {
  const [user, setUser] = useState<{ addr?: string; loggedIn?: boolean }>({ loggedIn: false });

  useEffect(() => {
    // Subscribe to FCL user changes
    fcl.currentUser.subscribe(setUser);
  }, []);

  const connect = () => {
    fcl.authenticate();
  };

  const disconnect = () => {
    fcl.unauthenticate();
  };

  if (!user.loggedIn) {
    return (
      <Button
        onClick={connect}
        className="bg-gradient-to-r from-primary to-accent hover:opacity-90 text-white border-0"
      >
        Connect Wallet
      </Button>
    );
  }

  return (
    <div className="flex gap-2">
      <Button
        variant="secondary"
        className="glass-card"
      >
        Flow Testnet
      </Button>

      <Button
        onClick={disconnect}
        className="glass-card"
      >
        {user.addr ? `${user.addr.slice(0, 6)}...${user.addr.slice(-4)}` : 'Connected'}
      </Button>
    </div>
  );
};
