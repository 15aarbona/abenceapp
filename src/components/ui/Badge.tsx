import React from 'react';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'red' | 'gold' | 'green' | 'gray' | 'blue';
  className?: string;
}

export function Badge({ children, variant = 'gray', className = '' }: BadgeProps) {
  const variants = {
    red: 'bg-fila-red/10 text-fila-red dark:bg-fila-red/20',
    gold: 'bg-gold/10 text-gold-dark dark:bg-gold/20 dark:text-gold',
    green: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
    gray: 'bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400',
    blue: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400',
  };

  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${variants[variant]} ${className}`}>
      {children}
    </span>
  );
}
