import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { User } from '../types';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<{ error?: string }>;
  logout: () => void;
  updateUser: (updates: Partial<User>) => Promise<{ error?: string }>;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  loading: true,
  login: async () => ({}),
  logout: () => {},
  updateUser: async () => ({}),
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check active sessions and sets the user
    const getSession = async () => {
      console.log('📡 Buscant sessió a Supabase...');
      
      // Fem que si tarda més de 6 segons, l'app no es quede penjada
      const timeout = setTimeout(() => {
        console.warn('⚠️ La sessió de Supabase està tardant massa. Forçant càrrega...');
        setLoading(false);
      }, 6000);

      try {
        const { data: { session }, error } = await supabase.auth.getSession();
        if (error) throw error;
        
        console.log('📡 Sessió trobada:', session ? 'SÍ' : 'NO');
        if (session) {
          await fetchUserData(session.user.id);
        }
      } catch (err) {
        console.error('❌ Error en getSession:', err);
      } finally {
        clearTimeout(timeout);
        setLoading(false);
      }
    };

    getSession();

    // Listen for changes on auth state
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      if (session) {
        await fetchUserData(session.user.id);
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const fetchUserData = async (userId: string) => {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) {
      console.error('Error fetching user metadata:', error);
      return;
    }
    setUser(data);
  };

  const login = async (email: string, password: string): Promise<{ error?: string }> => {
    console.log('🔐 Intentant login per a:', email);
    
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        console.error('❌ Error de Supabase Auth:', error.message);
        return { error: error.message };
      }

      console.log('✅ Login d\'Auth correcte, esperant dades de perfil...');
      if (data.user) {
        await fetchUserData(data.user.id);
      }
      return {};
    } catch (err: any) {
      console.error('💥 Error catastròfic en login:', err);
      return { error: err.message || 'Error desconegut' };
    }
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
  };

  const updateUser = async (updates: Partial<User>): Promise<{ error?: string }> => {
    if (!user) return { error: 'No hi ha usuari' };

    const { error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', user.id);

    if (error) {
      return { error: error.message };
    }

    setUser({ ...user, ...updates });
    return {};
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
export const DEMO_USERS_LIST: User[] = []; // We will fetch users from DB now
