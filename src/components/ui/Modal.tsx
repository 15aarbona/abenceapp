import React, { useEffect } from 'react';
import { X } from 'lucide-react';
import { useNav } from '../../contexts/NavContext';

interface ModalProps {
  open: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}

export function Modal({ open, onClose, title, children }: ModalProps) {
  const { hideNav, showNav } = useNav();

  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
      hideNav();
    } else {
      document.body.style.overflow = '';
      showNav();
    }
    return () => {
      document.body.style.overflow = '';
      showNav();
    };
  }, [open]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={onClose} />
      <div className="relative bg-white dark:bg-dark-card w-full sm:max-w-lg sm:rounded-2xl rounded-t-2xl max-h-[85vh] overflow-y-auto shadow-2xl">
        <div className="sticky top-0 bg-white dark:bg-dark-card flex items-center justify-between p-5 border-b border-light-border dark:border-dark-border z-10">
          <h2 className="text-lg font-bold text-gray-900 dark:text-white">{title}</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-xl hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <X size={20} className="text-gray-500" />
          </button>
        </div>
        <div className="p-5">{children}</div>
      </div>
    </div>
  );
}
