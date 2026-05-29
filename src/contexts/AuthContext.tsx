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
    console.log('🔍 Intentant llegir taula "users" per a:', userId);
    
    // Creem una promesa que falla als 4 segons per a no bloquejar l'app
    const timeoutPromise = new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Timeout BD')), 4000)
    );

    try {
      const fetchPromise = supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

      const result = await Promise.race([fetchPromise, timeoutPromise]) as any;
      const { data, error } = result;

      if (error) {
        console.error('❌ Error BD:', error.message);
        return null;
      }
      
      console.log('✅ Perfil rebut:', data ? 'TROBAT' : 'BUIT');
      return data;
    } catch (err) {
      console.warn('⚠️ No s\'ha pogut recuperar el perfil a temps (possible RLS o connexió)');
      return null;
    }
  };

  useEffect(() => {
    console.log('🏗️ AuthProvider carregat');

    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      console.log('🔔 Auth Event:', event);
      
      if (session?.user) {
        const profile = await fetchUserData(session.user.id);
        // Si no hi ha perfil, creem un objecte temporal per a que l'app no falle
        setUser(profile || { 
          id: session.user.id, 
          email: session.user.email || '', 
          nombre: 'Usuari', 
          apellidos: '', 
          is_admin: false 
        } as any);
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
