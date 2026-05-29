import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('⚠️ Falten les variables d\'entorn de Supabase! Revisa el panell de Netlify.');
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '');
