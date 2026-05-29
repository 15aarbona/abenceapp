import { createClient } from '@supabase/supabase-js';

// Netegem la URL per si té espais o rutes extres
const rawUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseUrl = rawUrl.replace(/\/rest\/v1\/?$/, '').trim();
const supabaseAnonKey = (import.meta.env.VITE_SUPABASE_ANON_KEY || '').trim();

console.log('🔗 Supabase Init - URL:', supabaseUrl);
if (!supabaseUrl) console.error('❌ VITE_SUPABASE_URL no definida!');
if (!supabaseAnonKey) console.error('❌ VITE_SUPABASE_ANON_KEY no definida!');

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  }
});
