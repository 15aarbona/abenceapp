import { useState, useEffect } from 'react';
import { Plus, Trash2, Check, Download, Clock, BarChart3, Vote as VoteIcon } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { dataStore } from '../store/dataStore';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input, Textarea } from '../components/ui/Input';
import type { Vote, VoteResponse, User } from '../types';
import * as XLSX from 'xlsx';

export function VotesPage() {
  const { user } = useAuth();
  const [votes, setVotes] = useState<Vote[]>([]);
  const [allUsers, setAllUsers] = useState<User[]>([]);
  const [selectedVote, setSelectedVote] = useState<Vote | null>(null);
  const [voteResponses, setVoteResponses] = useState<VoteResponse[]>([]);
  const [loading, setLoading] = useState(true);
  
  const [showNew, setShowNew] = useState(false);
  const [title, setTitle] = useState('');
  const [desc, setDesc] = useState('');
  const [options, setOptions] = useState<string[]>(['', '']);
  const [multiple, setMultiple] = useState(false);
  const [closeDate, setCloseDate] = useState('');
  const [selectedOptions, setSelectedOptions] = useState<string[]>([]);

  const today = new Date().toISOString().split('T')[0];

  useEffect(() => {
    fetchVotes();
    fetchAllUsers();
  }, []);

  const fetchVotes = async () => {
    setLoading(true);
    try {
      const data = await dataStore.getVotes();
      setVotes(data);
    } catch (error) {
      console.error('Error fetching votes:', error);
    }
    setLoading(false);
  };

  const fetchAllUsers = async () => {
    try {
      const users = await dataStore.getAllUsers();
      setAllUsers(users);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const fetchResponses = async (voteId: string) => {
    try {
      const responses = await dataStore.getVoteResponses(voteId);
      setVoteResponses(responses);
    } catch (error) {
      console.error('Error fetching responses:', error);
    }
  };

  const handleAddOption = () => setOptions([...options, '']);
  const handleRemoveOption = (idx: number) => {
    if (options.length <= 2) return;
    setOptions(options.filter((_, i) => i !== idx));
  };

  const handleCreate = async () => {
    if (!title.trim() || !closeDate || options.filter(o => o.trim()).length < 2) return;
    try {
      await dataStore.addVote({
        titulo: title,
        descripcion: desc,
        opciones: options.filter(o => o.trim()),
        multiple,
        fecha_cierre: closeDate,
        created_by: user!.id,
      });
      fetchVotes();
      setTitle(''); setDesc(''); setOptions(['', '']); setMultiple(false); setCloseDate('');
      setShowNew(false);
    } catch (error) {
      console.error('Error creating vote:', error);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await dataStore.deleteVote(id);
      fetchVotes();
      setSelectedVote(null);
    } catch (error) {
      console.error('Error deleting vote:', error);
    }
  };

  const handleVote = async () => {
    if (!selectedVote || selectedOptions.length === 0) return;
    try {
      await dataStore.addVoteResponse({
        vote_id: selectedVote.id,
        user_id: user!.id,
        opciones_elegidas: selectedOptions,
      });
      setSelectedOptions([]);
      fetchResponses(selectedVote.id);
      fetchVotes();
    } catch (error) {
      console.error('Error voting:', error);
    }
  };

  const toggleOption = (opt: string) => {
    if (selectedVote?.multiple) {
      setSelectedOptions(prev =>
        prev.includes(opt) ? prev.filter(o => o !== opt) : [...prev, opt]
      );
    } else {
      setSelectedOptions([opt]);
    }
  };

  const getUserVote = (): VoteResponse | undefined => {
    return voteResponses.find(r => r.user_id === user?.id);
  };

  const getResultCounts = () => {
    const counts: Record<string, number> = {};
    selectedVote?.opciones.forEach(o => counts[o] = 0);
    voteResponses.forEach(r => r.opciones_elegidas.forEach(o => { if (counts[o] !== undefined) counts[o]++; }));
    return counts;
  };

  const isOpen = (vote: Vote) => vote.fecha_cierre >= today;

  const exportVote = (vote: Vote) => {
    const data = voteResponses.map(r => {
      const userName = allUsers.find(u => u.id === r.user_id);
      return {
        'Usuari': userName ? `${userName.nombre} ${userName.apellidos}` : `Usuari #${r.user_id}`,
        'Opcions Elegides': r.opciones_elegidas.join(', '),
        'Data': r.created_at,
      };
    });
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Respostes');
    XLSX.writeFile(wb, `votacio_${vote.titulo.replace(/\s+/g, '_')}.xlsx`);
  };

  const formatDate = (d: string) => new Date(d + 'T00:00:00').toLocaleDateString('ca-ES', { day: 'numeric', month: 'short', year: 'numeric' });

  if (loading && votes.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-gold border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-5 animate-fadeIn">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs font-semibold text-blue-500 tracking-widest uppercase">Participació</p>
          <h2 className="text-2xl font-black text-gray-900 dark:text-white tracking-tight">Votacions</h2>
        </div>
        {user?.is_admin && (
          <Button size="sm" onClick={() => setShowNew(true)}>
            <Plus size={16} /> Nova
          </Button>
        )}
      </div>

      {votes.length === 0 ? (
        <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-3xl p-12 text-center">
          <VoteIcon size={40} className="mx-auto text-gray-300 dark:text-gray-600 mb-3" />
          <p className="text-gray-400 font-medium">No hi ha cap votació disponible</p>
        </div>
      ) : (
        <div className="space-y-3">
          {votes.map(v => {
            const open = isOpen(v);
            return (
              <div 
                key={v.id} 
                onClick={() => { setSelectedVote(v); fetchResponses(v.id); }}
                className="bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-2xl p-5 shadow-sm hover:shadow-md transition-all cursor-pointer relative overflow-hidden group"
              >
                {open && <div className="absolute left-0 top-0 bottom-0 w-1 bg-blue-500" />}
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex flex-wrap items-center gap-2 mb-1.5">
                      <h4 className="font-bold text-gray-900 dark:text-white text-base group-hover:text-blue-500 transition-colors">{v.titulo}</h4>
                      {open ? <Badge variant="green">Oberta</Badge> : <Badge variant="gray">Tancada</Badge>}
                      {v.multiple && <Badge variant="blue">Múltiple</Badge>}
                    </div>
                    <p className="text-sm text-gray-500 line-clamp-2 mb-3">{v.descripcion}</p>
                    <div className="flex items-center gap-4 text-xs text-gray-400 font-medium">
                      <span className="flex items-center gap-1"><Clock size={12} className="text-blue-500" /> Tanca: {formatDate(v.fecha_cierre)}</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Vote Detail Modal */}
      <Modal open={!!selectedVote} onClose={() => { setSelectedVote(null); setSelectedOptions([]); setVoteResponses([]); }} title={selectedVote?.titulo || ''}>
        {selectedVote && (() => {
          const open = isOpen(selectedVote);
          const userVote = getUserVote();
          const counts = getResultCounts();
          const totalVotes = voteResponses.length;

          return (
            <div className="space-y-5">
              <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed">{selectedVote.descripcion}</p>
              <div className="flex flex-wrap gap-2 text-xs">
                {open ? <Badge variant="green">Oberta</Badge> : <Badge variant="gray">Tancada</Badge>}
                {selectedVote.multiple && <Badge variant="blue">Selecció múltiple</Badge>}
                <Badge variant="gold">{totalVotes} vots emesos</Badge>
              </div>
              <div className="space-y-2.5 pt-2">
                {selectedVote.opciones.map((opt) => {
                  const isSelected = selectedOptions.includes(opt) || userVote?.opciones_elegidas.includes(opt);
                  const count = counts[opt] || 0;
                  const pct = totalVotes > 0 ? Math.round((count / totalVotes) * 100) : 0;
                  return (
                    <button
                      key={opt}
                      onClick={() => open && toggleOption(opt)}
                      disabled={!open}
                      className={`w-full text-left rounded-xl border p-3.5 transition-all relative overflow-hidden block ${isSelected ? 'border-gold bg-gradient-to-r from-gold/10 to-transparent' : 'border-light-border dark:border-dark-border'} ${!open ? 'cursor-default' : 'cursor-pointer'}`}
                    >
                      {totalVotes > 0 && <div className="absolute inset-y-0 left-0 bg-gradient-to-r from-gold/20 via-gold/10 to-transparent transition-all duration-1000 ease-out" style={{ width: `${pct}%` }} />}
                      <div className="relative z-10 flex items-center justify-between gap-2">
                        <div className="flex items-center gap-3">
                          {open && <div className={`w-5 h-5 rounded-full border flex items-center justify-center shrink-0 ${isSelected ? 'border-gold bg-gold' : 'border-gray-300 dark:border-gray-600'}`}>{isSelected && <Check size={12} className="text-black stroke-[3]" />}</div>}
                          <span className="text-sm font-bold text-gray-900 dark:text-white">{opt}</span>
                        </div>
                        {totalVotes > 0 && <span className="text-sm font-black text-gold tracking-tight shrink-0">{pct}% <span className="text-xs font-normal text-gray-400">({count})</span></span>}
                      </div>
                    </button>
                  );
                })}
              </div>
              {open && <div className="pt-2"><Button onClick={handleVote} disabled={selectedOptions.length === 0} className="w-full !py-3">{userVote ? 'Actualitzar el meu vot' : 'Confirmar Vot'}</Button></div>}
              {userVote && open && <p className="text-xs text-center text-green-600 dark:text-green-400 font-medium">✓ Ja has votat · Pots canviar la teua selecció</p>}
              {user?.is_admin && (
                <div className="flex gap-2 pt-3 border-t border-light-border dark:border-dark-border">
                  <Button variant="ghost" size="sm" onClick={() => exportVote(selectedVote)} className="flex-1 text-xs"><Download size={14} /> Exportar Excel</Button>
                  <Button variant="danger" size="sm" onClick={() => handleDelete(selectedVote.id)} className="text-xs"><Trash2 size={14} /> Eliminar</Button>
                </div>
              )}
              <p className="text-[11px] text-gray-400 text-center">Data límit: {formatDate(selectedVote.fecha_cierre)}</p>
            </div>
          );
        })()}
      </Modal>

      {/* Create Vote Modal */}
      <Modal open={showNew} onClose={() => setShowNew(false)} title="Nova Votació">
        <div className="space-y-4">
          <Input label="Títol" value={title} onChange={e => setTitle(e.target.value)} placeholder="Sobre què es vota?" />
          <Textarea label="Descripció" value={desc} onChange={e => setDesc(e.target.value)} placeholder="Descriu la votació..." />
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Opcions</label>
            {options.map((opt, i) => (
              <div key={i} className="flex gap-2 mb-2">
                <Input value={opt} onChange={e => { const newOpts = [...options]; newOpts[i] = e.target.value; setOptions(newOpts); }} placeholder={`Opció ${i + 1}`} />
                {options.length > 2 && <button onClick={() => handleRemoveOption(i)} className="p-2 text-red-400 hover:text-red-600"><Trash2 size={16} /></button>}
              </div>
            ))}
            <button onClick={handleAddOption} className="text-xs font-bold text-fila-red hover:underline block mt-1">+ Afegir opció</button>
          </div>
          <div className="flex items-center gap-3">
            <input type="checkbox" checked={multiple} onChange={e => setMultiple(e.target.checked)} className="w-4 h-4 rounded accent-fila-red" id="multiple" />
            <label htmlFor="multiple" className="text-sm text-gray-700 dark:text-gray-300">Permetre selecció múltiple</label>
          </div>
          <Input label="Data de tancament" type="date" value={closeDate} onChange={e => setCloseDate(e.target.value)} min={today} />
          <Button onClick={handleCreate} className="w-full">Crear Votació</Button>
        </div>
      </Modal>
    </div>
  );
}
