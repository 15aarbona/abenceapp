import { useState, useEffect } from 'react';
import { User, Camera, Save, Shield, CreditCard, Phone, Mail, Calendar, Edit3, Loader2 } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Modal } from '../components/ui/Modal';
import { supabase } from '../lib/supabase';

export function ProfilePage() {
  const { user, updateUser } = useAuth();
  const [editing, setEditing] = useState(false);
  const [uploading, setUploading] = useState(false);
  
  const [nombre, setNombre] = useState('');
  const [apellidos, setApellidos] = useState('');
  const [telefono, setTelefono] = useState('');
  const [email, setEmail] = useState('');
  const [fechaNacimiento, setFechaNacimiento] = useState('');

  // Actualitza els camps quan s'obre el mode edició o canvia l'usuari
  useEffect(() => {
    if (user) {
      setNombre(user.nombre || '');
      setApellidos(user.apellidos || '');
      setTelefono(user.telefono || '');
      setEmail(user.email || '');
      setFechaNacimiento(user.fecha_nacimiento || '');
    }
  }, [user, editing]);

  if (!user) return null;

  const calcAge = (dob: string) => {
    const birth = new Date(dob);
    const now = new Date();
    let age = now.getFullYear() - birth.getFullYear();
    const m = now.getMonth() - birth.getMonth();
    if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age--;
    return age;
  };

  const age = calcAge(user.fecha_nacimiento);
  const formatDob = new Date(user.fecha_nacimiento + 'T00:00:00').toLocaleDateString('ca-ES', { day: 'numeric', month: 'long', year: 'numeric' });

  const tipoLabel: Record<string, string> = { nino: 'Xiquet', joven: 'Jove', adulto: 'Adult' };
  const cuotaLabel: Record<string, string> = { basica: 'Bàsica', full: 'Full', joven: 'Jove' };
  const tipoBadge: Record<string, 'red' | 'gold' | 'green' | 'gray' | 'blue'> = { nino: 'green', joven: 'blue', adulto: 'red' };

  const handleSave = async () => {
    await updateUser({ 
      nombre, 
      apellidos, 
      telefono, 
      email, 
      fecha_nacimiento: fechaNacimiento 
    });
    setEditing(false);
  };

  const handleUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    try {
      setUploading(true);
      if (!event.target.files || event.target.files.length === 0) return;
      
      const file = event.target.files[0];
      const fileExt = file.name.split('.').pop();
      const filePath = `${user!.id}-${Math.random()}.${fileExt}`;

      // 1. Pujar a Supabase Storage
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, file);

      if (uploadError) throw uploadError;

      // 2. Obtenir URL pública
      const { data: { publicUrl } } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath);

      // 3. Actualitzar perfil
      await updateUser({ foto_url: publicUrl });
      
    } catch (error: any) {
      alert('Error pujant la foto: ' + error.message);
    } finally {
      setUploading(false);
    }
  };

  const getInitials = () => {
    return `${user.nombre.charAt(0)}${user.apellidos.charAt(0)}`.toUpperCase();
  };

  return (
    <div className="space-y-6 animate-fadeIn">
      <div className="text-center relative">
        <div className="relative inline-block mt-4">
          <div className="w-28 h-28 rounded-full bg-gradient-to-tr from-fila-red via-gold to-fila-red-dark p-1 shadow-xl mx-auto">
            <div className="w-full h-full rounded-full bg-white dark:bg-dark-card flex items-center justify-center overflow-hidden">
              {user.foto_url ? (<img src={user.foto_url} alt={user.nombre} className="w-full h-full object-cover" />) : (<span className="text-3xl font-black text-gray-800 dark:text-gray-200">{getInitials()}</span>)}
            </div>
          </div>
          <label 
            htmlFor="photo-upload" 
            className="absolute bottom-0 right-0 w-8 h-8 bg-gold rounded-full flex items-center justify-center shadow-lg hover:scale-110 active:scale-95 transition-transform text-black cursor-pointer"
          >
            {uploading ? <Loader2 size={14} className="animate-spin" /> : <Camera size={14} />}
            <input
              type="file"
              id="photo-upload"
              accept="image/*"
              className="hidden"
              onChange={handleUpload}
              disabled={uploading}
            />
          </label>
        </div>
        <h3 className="text-xl font-black text-gray-900 dark:text-white mt-3 tracking-tight">{user.nombre} {user.apellidos}</h3>
        <div className="flex items-center justify-center gap-1.5 mt-2">
          <Badge variant={tipoBadge[user.tipo_usuario]}>{tipoLabel[user.tipo_usuario]}</Badge>
          {user.is_admin && <Badge variant="gold"><Shield size={10} className="mr-1" />Admin</Badge>}
          <Badge variant="gray">{cuotaLabel[user.tipo_cuota]}</Badge>
        </div>
      </div>

      <div className="bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-3xl p-6 shadow-sm relative overflow-hidden">
        <div className="absolute -right-10 -bottom-10 w-40 h-40 bg-fila-red/5 rounded-full blur-2xl pointer-events-none" />
        <div className="flex items-center justify-between mb-5">
          <h4 className="font-black text-gray-900 dark:text-white tracking-tight text-sm uppercase text-gray-400">Dades Personals</h4>
          <button onClick={() => setEditing(true)} className="text-xs font-bold text-fila-red hover:text-fila-red-dark flex items-center gap-1 transition-colors"><Edit3 size={14} /> Editar</button>
        </div>
        <div className="space-y-4">
          <InfoRow icon={<User size={18} />} label="Nom complet" value={`${user.nombre} ${user.apellidos}`} />
          <InfoRow icon={<Mail size={18} />} label="Correu electrònic" value={user.email} />
          <InfoRow icon={<Phone size={18} />} label="Telèfon mòbil" value={user.telefono} />
          <InfoRow icon={<Calendar size={18} />} label="Data de naixement" value={`${formatDob} (${age} anys)`} />
          <InfoRow icon={<CreditCard size={18} />} label="Tipus de quota" value={cuotaLabel[user.tipo_cuota]} />
        </div>
      </div>

      <Modal open={editing} onClose={() => setEditing(false)} title="Editar Perfil">
        <div className="space-y-4">
          <Input label="Nom" value={nombre} onChange={e => setNombre(e.target.value)} />
          <Input label="Cognoms" value={apellidos} onChange={e => setApellidos(e.target.value)} />
          <Input label="Data de naixement" type="date" value={fechaNacimiento} onChange={e => setFechaNacimiento(e.target.value)} />
          <Input label="Correu electrònic" type="email" value={email} onChange={e => setEmail(e.target.value)} />
          <Input label="Telèfon" value={telefono} onChange={e => setTelefono(e.target.value)} />
          <Button onClick={handleSave} className="w-full !py-3"><Save size={16} /> Guardar Canvis</Button>
        </div>
      </Modal>
    </div>
  );
}

function InfoRow({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-start gap-3">
      <div className="w-8 h-8 rounded-lg bg-gray-50 dark:bg-gray-800 flex items-center justify-center text-gray-400 shrink-0 mt-0.5">{icon}</div>
      <div className="flex-1 min-w-0"><p className="text-[11px] font-medium text-gray-400">{label}</p><p className="text-sm font-bold text-gray-800 dark:text-gray-200 truncate">{value}</p></div>
    </div>
  );
}
