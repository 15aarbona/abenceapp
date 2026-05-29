import React from 'react';
import { Home, Vote, Calendar, ShoppingBag, User, Sun, Moon, LogOut } from 'lucide-react';
import { useTheme } from '../contexts/ThemeContext';
import { useAuth } from '../contexts/AuthContext';
import { useNav } from '../contexts/NavContext';

interface LayoutProps {
  children: React.ReactNode;
  currentPage: string;
  onNavigate: (page: string) => void;
}

const NAV_ITEMS = [
  { id: 'orders', icon: ShoppingBag },
  { id: 'events', icon: Calendar },
  { id: 'home', icon: Home },
  { id: 'votes', icon: Vote },
  { id: 'profile', icon: User },
];

export function Layout({ children, currentPage, onNavigate }: LayoutProps) {
  const { dark, toggle } = useTheme();
  const { logout } = useAuth();
  const { navVisible } = useNav();

  return (
    <div className="min-h-screen bg-light-bg dark:bg-dark-bg flex flex-col transition-colors duration-300 overflow-y-auto">
      {/* Background ambient blobs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-0 right-0 w-96 h-96 bg-fila-red/5 dark:bg-fila-red/10 rounded-full blur-3xl -mr-20 -mt-20 transition-all duration-1000" />
        <div className="absolute top-1/3 left-0 w-96 h-96 bg-gold/5 dark:bg-gold/10 rounded-full blur-3xl -ml-20 transition-all duration-1000" />
      </div>

      {/* Top bar */}
      <header className="sticky top-0 z-40 px-4 py-3">
        <div className="max-w-2xl mx-auto flex justify-end items-center gap-2">
          <button
            onClick={toggle}
            className="p-2.5 rounded-full bg-white/80 dark:bg-dark-card/80 backdrop-blur-md border border-light-border dark:border-dark-border shadow-sm hover:scale-105 active:scale-95 transition-all text-gray-700 dark:text-gray-300"
            title={dark ? 'Mode clar' : 'Mode fosc'}
          >
            {dark ? <Sun size={18} className="text-gold" /> : <Moon size={18} className="text-gray-700" />}
          </button>
          <button
            onClick={logout}
            className="p-2.5 rounded-full bg-white/80 dark:bg-dark-card/80 backdrop-blur-md border border-light-border dark:border-dark-border shadow-sm hover:scale-105 active:scale-95 transition-all text-gray-700 dark:text-gray-300 hover:text-fila-red dark:hover:text-fila-red"
            title="Tancar sessió"
          >
            <LogOut size={18} />
          </button>
        </div>
      </header>

      {/* Content */}
      <main className="flex-1 max-w-2xl mx-auto w-full px-4 py-2 pb-32 relative z-10">
        {children}
      </main>

      {/* Bottom navigation */}
      <div className={`fixed bottom-5 left-0 right-0 z-40 flex justify-center safe-area-bottom transition-all duration-300 ${navVisible ? 'translate-y-0 opacity-100' : 'translate-y-24 opacity-0 pointer-events-none'}`}>
        <nav className="glass-premium border border-white/20 dark:border-white/10 rounded-full shadow-lg shadow-black/5 dark:shadow-black/20 px-3 py-2 flex items-center gap-1">
          {NAV_ITEMS.map((item) => {
            const active = currentPage === item.id;
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                onClick={() => onNavigate(item.id)}
                className={`relative flex items-center justify-center w-12 h-12 rounded-full transition-all duration-300 ${
                  active
                    ? 'text-white'
                    : 'text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300'
                }`}
              >
                {active && (
                  <div className="absolute inset-0 bg-gradient-to-r from-fila-red to-fila-red-dark rounded-full shadow-md shadow-fila-red/30" />
                )}
                <Icon size={22} strokeWidth={active ? 2.5 : 1.8} className="relative z-10 transition-transform duration-200 active:scale-90" />
              </button>
            );
          })}
        </nav>
      </div>
    </div>
  );
}
