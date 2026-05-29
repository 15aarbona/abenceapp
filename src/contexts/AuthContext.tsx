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

  // Funció centralitzada per a carregar dades de l'usuari
  const fetchUserData = async (userId: string) => {
    console.log('🔍 Recuperant perfil de la BD per a:', userId);
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle(); // maybeSingle és més segur que single si l'usuari no existeix encara

      if (error) {
        console.error('❌ Error recuperant perfil:', error.message);
        return null;
      }
      
      if (!data) {
        console.warn('⚠️ L\'usuari existeix en Auth però no en la taula "users"');
      }

      return data;
    } catch (err) {
      console.error('💥 Error inesperat en fetchUserData:', err);
      return null;
    }
  };

  useEffect(() => {
    console.log('🏗️ Iniciant AuthProvider...');

    // Escoltador d'estat d'autenticació (gestiona inici, tancament i sessió persistent)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('🔔 Canvi d\'estat Auth:', event);
      
      if (session?.user) {
        const profile = await fetchUserData(session.user.id);
        setUser(profile);
      } else {
        setUser(null);
      }
      
      setLoading(false);
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const login = async (email: string, password: string): Promise<{ error?: string }> => {
    console.log('🔐 Intentant login...');
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        console.error('❌ Error de login:', error.message);
        return { error: 'Correu o contrasenya incorrectes' };
      }

      // No cal fer res més, onAuthStateChange s'encarregarà de carregar l'usuari
      return {};
    } catch (err: any) {
      return { error: err.message || 'Error en la connexió' };
    }
  };

  const logout = async () => {
    console.log('🚪 Tancant sessió...');
    await supabase.auth.signOut();
    setUser(null);
  };

  const updateUser = async (updates: Partial<User>): Promise<{ error?: string }> => {
    if (!user) return { error: 'No hi ha usuari actiu' };
    try {
      const { error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', user.id);

      if (error) throw error;
      setUser({ ...user, ...updates });
      return {};
    } catch (err: any) {
      return { error: err.message };
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, updateUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
export const DEMO_USERS_LIST: User[] = [];
