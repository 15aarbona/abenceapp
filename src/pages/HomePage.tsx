import { useState, useEffect } from 'react';
import { Megaphone, Calendar, Vote, Plus, Trash2, PartyPopper, ChefHat, Clock, ChevronRight } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { dataStore } from '../store/dataStore';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input, Textarea } from '../components/ui/Input';
import type { Announcement, Event, Vote as VoteType } from '../types';

interface HomePageProps {
  onNavigate: (page: string) => void;
}

export function HomePage({ onNavigate }: HomePageProps) {
  const { user } = useAuth();
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [upcomingEvents, setUpcomingEvents] = useState<Event[]>([]);
  const [upcomingVotes, setUpcomingVotes] = useState<VoteType[]>([]);
  const [loading, setLoading] = useState(true);

  const [showNewAnnouncement, setShowNewAnnouncement] = useState(false);
  const [newTitle, setNewTitle] = useState('');
  const [newMessage, setNewMessage] = useState('');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [annData, evtData, voteData] = await Promise.all([
        dataStore.getAnnouncements(),
        dataStore.getUpcomingEvents(5),
        dataStore.getVotes()
      ]);
      setAnnouncements(annData);
      setUpcomingEvents(evtData);
      setUpcomingVotes(voteData.filter(v => v.fecha_cierre >= new Date().toISOString().split('T')[0]).slice(0, 5));
    } catch (error) {
      console.error('Error fetching home data:', error);
    }
    setLoading(false);
  };

  const handleAddAnnouncement = async () => {
    if (!newTitle.trim() || !newMessage.trim()) return;
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    try {
      await dataStore.addAnnouncement({
        titulo: newTitle,
        mensaje: newMessage,
        created_by: user!.id,
        expires_at: expiresAt.toISOString().split('T')[0],
        is_birthday: false,
      });
      fetchData();
      setNewTitle('');
      setNewMessage('');
      setShowNewAnnouncement(false);
    } catch (error) {
      console.error('Error adding announcement:', error);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await dataStore.deleteAnnouncement(id);
      fetchData();
    } catch (error) {
      console.error('Error deleting announcement:', error);
    }
  };

  const formatDate = (dateStr: string) => {
    const d = new Date(dateStr + 'T00:00:00');
    return d.toLocaleDateString('ca-ES', { day: 'numeric', month: 'short' });
  };

  const daysUntil = (dateStr: string) => {
    const now = new Date();
    now.setHours(0,0,0,0);
    const target = new Date(dateStr + 'T00:00:00');
    const diff = Math.ceil((target.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    if (diff === 0) return 'Hui';
    if (diff === 1) return 'Demà';
    return `En ${diff} dies`;
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-gold border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-7 animate-fadeIn">
      {/* Header premium */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold text-gold tracking-widest uppercase">Moros i Cristians</p>
          <h1 className="text-2xl font-black text-gray-900 dark:text-white tracking-tight">
            Hola, {user?.nombre}! 👋
          </h1>
        </div>
        <div 
          onClick={() => onNavigate('profile')} 
          className="w-12 h-12 rounded-full bg-gradient-to-tr from-fila-red to-gold p-0.5 cursor-pointer shadow-md hover:scale-105 transition-transform"
        >
          <div className="w-full h-full rounded-full bg-white dark:bg-dark-card flex items-center justify-center overflow-hidden">
            {user?.foto_url ? (
              <img src={user.foto_url} alt={user.nombre} className="w-full h-full object-cover" />
            ) : (
              <span className="text-sm font-bold text-gray-800 dark:text-gray-200">
                {user?.nombre.charAt(0)}{user?.apellidos.charAt(0)}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* ANUNCIS */}
      <section className="space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-fila-red animate-pulse" />
            <h3 className="text-sm font-bold text-gray-500 tracking-wider uppercase">Tauler d'Anuncis</h3>
          </div>
          {user?.is_admin && (
            <button 
              onClick={() => setShowNewAnnouncement(true)}
              className="text-xs font-bold text-fila-red hover:text-fila-red-dark flex items-center gap-1"
            >
              <Plus size={14} /> Nou
            </button>
          )}
        </div>

        {announcements.length === 0 ? (
          <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-2xl p-4 text-center">
            <p className="text-xs text-gray-400">No hi ha anuncis actius.</p>
          </div>
        ) : (
          <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4">
            {announcements.map((a) => (
              <div
                key={a.id}
                className={`w-72 shrink-0 rounded-2xl p-4 shadow-sm border select-none relative overflow-hidden ${
                  a.is_birthday
                    ? 'bg-gradient-to-br from-gold/10 via-white to-gold/5 dark:from-gold/10 dark:via-dark-card dark:to-gold/5 border-gold/30'
                    : 'bg-white dark:bg-dark-card border-light-border dark:border-dark-border'
                }`}
              >
                <div className={`absolute top-0 left-0 right-0 h-1 ${a.is_birthday ? 'bg-gold' : 'bg-gradient-to-r from-fila-red to-gold'}`} />
                <div className="flex items-start justify-between gap-2 mb-2">
                  <div className="flex items-center gap-1.5">
                    {a.is_birthday ? (
                      <PartyPopper size={16} className="text-gold shrink-0" />
                    ) : (
                      <Megaphone size={14} className="text-fila-red shrink-0" />
                    )}
                    <h4 className="font-bold text-gray-900 dark:text-white text-sm leading-tight line-clamp-1">
                      {a.titulo}
                    </h4>
                  </div>
                  {user?.is_admin && !a.is_birthday && (
                    <button 
                      onClick={(e) => { e.stopPropagation(); handleDelete(a.id); }}
                      className="p-1 rounded-lg text-gray-400 hover:text-red-500 transition-colors shrink-0"
                    >
                      <Trash2 size={14} />
                    </button>
                  )}
                </div>
                <p className="text-gray-600 dark:text-gray-300 text-xs leading-relaxed line-clamp-3 mb-3">
                  {a.mensaje}
                </p>
                <div className="pt-2 border-t border-light-border dark:border-dark-border text-[11px] font-semibold text-gray-400">
                  {a.is_birthday ? '🎉 Només hui' : `📅 Expira: ${formatDate(a.expires_at)}`}
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* PRÒXIMS ESDEVENIMENTS */}
      <section className="space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-bold text-gray-500 tracking-wider uppercase">Pròxims Esdeveniments</h3>
          <button 
            onClick={() => onNavigate('events')} 
            className="text-xs font-bold text-gold hover:text-gold-dark flex items-center gap-0.5"
          >
            Veure tots <ChevronRight size={14} />
          </button>
        </div>

        {upcomingEvents.length === 0 ? (
          <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-2xl p-4 text-center">
            <p className="text-xs text-gray-400">No hi ha esdeveniments pròxims.</p>
          </div>
        ) : (
          <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4">
            {upcomingEvents.map((evt) => (
              <div 
                key={evt.id}
                onClick={() => onNavigate('events')}
                className="w-64 shrink-0 bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-2xl p-4 shadow-sm hover:shadow-md transition-all cursor-pointer hover:-translate-y-1 select-none"
              >
                <div className="flex items-center justify-between mb-3">
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${evt.tipo === 'comida' ? 'bg-gold/10' : 'bg-fila-red/10'}`}>
                    {evt.tipo === 'comida' ? <ChefHat size={20} className="text-gold" /> : <Calendar size={20} className="text-fila-red" />}
                  </div>
                  <Badge variant={evt.tipo === 'comida' ? 'gold' : 'red'}>{daysUntil(evt.fecha_evento)}</Badge>
                </div>
                <h4 className="font-bold text-gray-900 dark:text-white text-sm line-clamp-1 mb-1">
                  {evt.titulo}
                </h4>
                <p className="text-xs text-gray-500 line-clamp-2 mb-3">
                  {evt.descripcion}
                </p>
                <div className="flex items-center gap-1.5 text-xs font-semibold text-gray-400 pt-2 border-t border-light-border dark:border-dark-border">
                  <Clock size={12} />
                  <span>{formatDate(evt.fecha_evento)} {evt.hora_evento ? `· ${evt.hora_evento}` : ''}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* VOTACIONS */}
      <section className="space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-bold text-gray-500 tracking-wider uppercase">Votacions en curs</h3>
          <button 
            onClick={() => onNavigate('votes')} 
            className="text-xs font-bold text-blue-500 hover:text-blue-600 flex items-center gap-0.5"
          >
            Veure totes <ChevronRight size={14} />
          </button>
        </div>

        {upcomingVotes.length === 0 ? (
          <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-2xl p-4 text-center">
            <p className="text-xs text-gray-400">No hi ha votacions actives.</p>
          </div>
        ) : (
          <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4">
            {upcomingVotes.map((v) => (
              <div 
                key={v.id} 
                onClick={() => onNavigate('votes')}
                className="w-64 shrink-0 bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-2xl p-4 shadow-sm hover:shadow-md transition-all cursor-pointer hover:-translate-y-1 select-none relative overflow-hidden group"
              >
                <div className="absolute top-0 right-0 w-20 h-20 bg-blue-500/5 rounded-full blur-xl group-hover:scale-150 transition-transform" />
                <div className="flex items-center justify-between mb-3">
                  <div className="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center">
                    <Vote size={20} className="text-blue-500" />
                  </div>
                  <Badge variant={v.multiple ? 'blue' : 'gray'}>{v.multiple ? 'Múltiple' : 'Única'}</Badge>
                </div>
                <h4 className="font-bold text-gray-900 dark:text-white text-sm line-clamp-1 mb-1">
                  {v.titulo}
                </h4>
                <p className="text-xs text-gray-500 line-clamp-2 mb-3">
                  {v.descripcion}
                </p>
                <div className="flex items-center justify-between pt-2 border-t border-light-border dark:border-dark-border">
                  <span className="text-[11px] font-semibold text-gray-400 flex items-center gap-1">
                    <Clock size={11} /> Tanca: {formatDate(v.fecha_cierre)}
                  </span>
                  <span className="text-[11px] font-bold text-blue-500 group-hover:translate-x-0.5 transition-transform">
                    Votar →
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* New Announcement Modal */}
      <Modal open={showNewAnnouncement} onClose={() => setShowNewAnnouncement(false)} title="Nou Anunci">
        <div className="space-y-4">
          <Input label="Títol" value={newTitle} onChange={(e) => setNewTitle(e.target.value)} placeholder="Títol de l'anunci" />
          <Textarea label="Missatge" value={newMessage} onChange={(e) => setNewMessage(e.target.value)} placeholder="Escriu el missatge..." />
          <p className="text-xs text-gray-400">L'anunci estarà visible durant 7 dies.</p>
          <Button onClick={handleAddAnnouncement} className="w-full">Publicar Anunci</Button>
        </div>
      </Modal>
    </div>
  );
}
