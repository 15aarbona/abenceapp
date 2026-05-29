import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Eye, EyeOff } from 'lucide-react';
import { Button } from '../components/ui/Button';

export function LoginPage() {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPass, setShowPass] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    // Timeout de seguretat
    const timer = setTimeout(() => {
      if (loading) {
        setLoading(false);
        setError('El servidor tarda massa en respondre. Revisa la teua connexió.');
      }
    }, 10000);

    const result = await login(email, password);
    clearTimeout(timer);
    
    if (result.error) {
      setError(result.error);
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-900 via-black to-gray-900 p-4">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-fila-red/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-gold/10 rounded-full blur-3xl" />
      </div>

      <div className="relative w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-8">
          <img src="/images/fila-logo.png" alt="Filà Logo" className="w-24 h-24 rounded-2xl shadow-2xl shadow-fila-red/30 mb-4 mx-auto object-cover" />
          <h1 className="text-3xl font-black text-white">Filà App</h1>
          <p className="text-gray-400 mt-1">Moros i Cristians</p>
        </div>

        {/* Login form */}
        <form onSubmit={handleSubmit} className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-3xl p-6 space-y-5">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1.5">Correu electrònic</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="el-teu@correu.com"
              className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-fila-red/50 focus:border-fila-red transition-all"
              required
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1.5">Contrasenya</label>
            <div className="relative">
              <input
                type={showPass ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="El teu número de telèfon"
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-fila-red/50 focus:border-fila-red transition-all pr-12"
                required
              />
              <button
                type="button"
                onClick={() => setShowPass(!showPass)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
              >
                {showPass ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
          </div>

          {error && (
            <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-3">
              <p className="text-sm text-red-400">{error}</p>
            </div>
          )}

          <Button type="submit" disabled={loading} className="w-full !py-3 !text-base">
            {loading ? 'Iniciant sessió...' : 'Iniciar Sessió'}
          </Button>
        </form>


      </div>
    </div>
  );
}
