import { useState, useEffect } from 'react';
import { Plus, Trash2, Calendar, ChefHat, Users, Download, Star, UserPlus, UserMinus, Clock, Shirt } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { dataStore } from '../store/dataStore';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input, Textarea, Select } from '../components/ui/Input';
import type { Event, EventAttendee, User } from '../types';
import * as XLSX from 'xlsx';

export function EventsPage() {
  const { user } = useAuth();
  const [events, setEvents] = useState<Event[]>([]);
  const [allUsers, setAllUsers] = useState<User[]>([]);
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null);
  const [attendees, setAttendees] = useState<EventAttendee[]>([]);
  const [loading, setLoading] = useState(true);
  
  const [showNew, setShowNew] = useState(false);
  const [showAddGuest, setShowAddGuest] = useState(false);

  // Form fields
  const [tipo, setTipo] = useState<'evento' | 'comida'>('evento');
  const [titulo, setTitulo] = useState('');
  const [desc, setDesc] = useState('');
  const [fecha, setFecha] = useState('');
  const [hora, setHora] = useState('');
  const [vestimenta, setVestimenta] = useState('');
  const [menuOptions, setMenuOptions] = useState<string[]>(['', '']);

  // Guest form
  const [guestName, setGuestName] = useState('');
  const [isChild, setIsChild] = useState(false);
  const [guestMenu, setGuestMenu] = useState('');

  // Rating form
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [editingRating, setEditingRating] = useState(false);

  const today = new Date().toISOString().split('T')[0];

  useEffect(() => {
    fetchEvents();
    fetchAllUsers();
  }, []);

  const fetchEvents = async () => {
    setLoading(true);
    try {
      const data = await dataStore.getEvents();
      setEvents(data);
    } catch (error) {
      console.error('Error fetching events:', error);
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

  const fetchAttendees = async (eventId: string) => {
    try {
      const data = await dataStore.getEventAttendees(eventId);
      setAttendees(data);
    } catch (error) {
      console.error('Error fetching attendees:', error);
    }
  };

  const handleCreate = async () => {
    if (!titulo.trim() || !fecha) return;
    try {
      await dataStore.addEvent({
        tipo,
        titulo,
        descripcion: desc,
        fecha_evento: fecha,
        hora_evento: hora || undefined,
        codigo_vestimenta: tipo === 'evento' ? vestimenta || undefined : undefined,
        opciones_menu: tipo === 'comida' ? menuOptions.filter(m => m.trim()) : undefined,
        created_by: user!.id,
      });
      fetchEvents();
      setTipo('evento'); setTitulo(''); setDesc(''); setFecha(''); setHora('');
      setVestimenta(''); setMenuOptions(['', '']);
      setShowNew(false);
    } catch (error) {
      console.error('Error creating event:', error);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await dataStore.deleteEvent(id);
      fetchEvents();
      setSelectedEvent(null);
    } catch (error) {
      console.error('Error deleting event:', error);
    }
  };

  const handleJoin = async (evt: Event, menu?: string) => {
    try {
      await dataStore.addEventAttendee({
        event_id: evt.id,
        user_id: user!.id,
        menu_elegido: menu,
        es_invitado: false,
        es_hijo: false,
      });
      fetchAttendees(evt.id);
      fetchEvents();
    } catch (error) {
      console.error('Error joining event:', error);
    }
  };

  const handleLeave = async (evt: Event) => {
    const mine = attendees.find(a => a.user_id === user!.id && !a.es_invitado && !a.es_hijo);
    if (mine) {
      try {
        await dataStore.removeEventAttendee(mine.id);
        fetchAttendees(evt.id);
        fetchEvents();
      } catch (error) {
        console.error('Error leaving event:', error);
      }
    }
  };

  const handleAddGuest = async (evt: Event) => {
    if (!guestName.trim()) return;
    try {
      await dataStore.addEventAttendee({
        event_id: evt.id,
        user_id: user!.id,
        menu_elegido: guestMenu || undefined,
        es_invitado: !isChild,
        nombre_invitado: !isChild ? guestName : undefined,
        invitado_de: user!.id,
        es_hijo: isChild,
        nombre_hijo: isChild ? guestName : undefined,
      });
      setGuestName(''); setIsChild(false); setGuestMenu('');
      setShowAddGuest(false);
      fetchAttendees(evt.id);
      fetchEvents();
    } catch (error) {
      console.error('Error adding guest:', error);
    }
  };

  const handleRemoveGuest = async (attendeeId: string, evt: Event) => {
    try {
      await dataStore.removeEventAttendee(attendeeId);
      fetchAttendees(evt.id);
      fetchEvents();
    } catch (error) {
      console.error('Error removing guest:', error);
    }
  };

  const handleRate = async (evt: Event) => {
    const mine = attendees.find(a => a.user_id === user!.id && !a.es_invitado && !a.es_hijo);
    if (mine) {
      try {
        await dataStore.updateEventAttendee(mine.id, { valoracion_comida: rating, comentario: comment });
        fetchAttendees(evt.id);
        setRating(0); setComment('');
        setEditingRating(false);
      } catch (error) {
        console.error('Error rating:', error);
      }
    }
  };

  const exportEvent = (evt: Event) => {
    const data = attendees.map(a => {
      const memberName = allUsers.find(u => u.id === a.user_id);
      const invitedByName = a.invitado_de ? allUsers.find(u => u.id === a.invitado_de) : null;
      return {
        'Nom': a.es_invitado ? a.nombre_invitado : (a.es_hijo ? a.nombre_hijo : (memberName ? `${memberName.nombre} ${memberName.apellidos}` : `Usuari ${a.user_id}`)),
        'Tipus': a.es_invitado ? 'Convidat' : (a.es_hijo ? 'Fill/a' : 'Membre'),
        'Convidat de': invitedByName ? `${invitedByName.nombre} ${invitedByName.apellidos}` : '-',
        'Menú': a.menu_elegido || '-',
        'Valoració': a.valoracion_comida || '-',
        'Comentari': a.comentario || '-',
      };
    });
    const ws = XLSX.utils.json_to_sheet(data);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Participants');
    XLSX.writeFile(wb, `esdeveniment_${evt.titulo.replace(/\s+/g, '_')}.xlsx`);
  };

  const formatDate = (d: string) => new Date(d + 'T00:00:00').toLocaleDateString('ca-ES', { weekday: 'short', day: 'numeric', month: 'short' });

  const isAttending = (): boolean => {
    return attendees.some(a => a.user_id === user?.id && !a.es_invitado && !a.es_hijo);
  };

  if (loading && events.length === 0) {
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
          <p className="text-xs font-semibold text-gold tracking-widest uppercase">Calendari</p>
          <h2 className="text-2xl font-black text-gray-900 dark:text-white tracking-tight">Esdeveniments</h2>
        </div>
        {user?.is_admin && <Button size="sm" onClick={() => setShowNew(true)}><Plus size={16} /> Nou</Button>}
      </div>

      {events.length === 0 ? (
        <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-3xl p-12 text-center">
          <Calendar size={40} className="mx-auto text-gray-300 dark:text-gray-600 mb-3" />
          <p className="text-gray-400 font-medium">No hi ha cap esdeveniment programat</p>
        </div>
      ) : (
        <div className="space-y-3.5">
          {events.map(evt => {
            const isPast = evt.fecha_evento < today;
            return (
              <div 
                key={evt.id} 
                onClick={() => { setSelectedEvent(evt); fetchAttendees(evt.id); }} 
                className={`bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-2xl p-5 shadow-sm hover:shadow-md transition-all cursor-pointer relative overflow-hidden group ${isPast ? 'opacity-60 hover:opacity-90' : ''}`}
              >
                <div className={`absolute top-0 left-0 right-0 h-1 ${evt.tipo === 'comida' ? 'bg-gold' : 'bg-fila-red'}`} />
                <div className="flex gap-4">
                  <div className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${evt.tipo === 'comida' ? 'bg-gold/10 text-gold' : 'bg-fila-red/10 text-fila-red'}`}>
                    {evt.tipo === 'comida' ? <ChefHat size={24} /> : <Calendar size={24} />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2 mb-1">
                      <h4 className="font-bold text-gray-900 dark:text-white text-base group-hover:text-gold transition-colors">{evt.titulo}</h4>
                      <Badge variant={evt.tipo === 'comida' ? 'gold' : 'red'}>{evt.tipo === 'comida' ? 'Menjar' : 'Festa'}</Badge>
                      {isPast && <Badge variant="gray">Passat</Badge>}
                    </div>
                    <div className="flex items-center gap-3 text-xs text-gray-500 font-medium mb-3">
                      <span className="flex items-center gap-1"><Clock size={12} className="text-gray-400" /> {formatDate(evt.fecha_evento)} {evt.hora_evento ? `· ${evt.hora_evento}` : ''}</span>
                    </div>
                    <div className="flex items-center justify-between pt-2 border-t border-light-border dark:border-dark-border">
                      <span className="text-xs font-bold text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">Detalls →</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Event Detail Modal */}
      <Modal open={!!selectedEvent} onClose={() => { setSelectedEvent(null); setAttendees([]); }} title={selectedEvent?.titulo || ''}>
        {selectedEvent && (() => {
          const attending = isAttending();
          const isPast = selectedEvent.fecha_evento < today;
          const myAttendance = attendees.find(a => a.user_id === user?.id && !a.es_invitado && !a.es_hijo);
          const myGuests = attendees.filter(a => a.invitado_de === user?.id);

          return (
            <div className="space-y-5">
              <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed">{selectedEvent.descripcion}</p>
              <div className="flex flex-wrap gap-3 p-3 bg-gray-50 dark:bg-gray-800/50 rounded-xl text-xs font-medium text-gray-600 dark:text-gray-300">
                <div className="flex items-center gap-1.5"><Clock size={14} className="text-gold" /><span>{formatDate(selectedEvent.fecha_evento)} {selectedEvent.hora_evento ? `· ${selectedEvent.hora_evento}` : ''}</span></div>
                {selectedEvent.codigo_vestimenta && <div className="flex items-center gap-1.5"><Shirt size={14} className="text-fila-red" /><span>{selectedEvent.codigo_vestimenta}</span></div>}
              </div>

              {selectedEvent.tipo === 'comida' && selectedEvent.opciones_menu && !attending && !isPast && (
                <div className="space-y-2">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Tria el teu menú per a assistir:</p>
                  <div className="grid grid-cols-1 gap-2">
                    {selectedEvent.opciones_menu.map(menu => (
                      <button key={menu} onClick={() => handleJoin(selectedEvent, menu)} className="text-left p-3 rounded-xl border border-light-border dark:border-dark-border hover:border-gold hover:bg-gold/5 transition-all text-sm font-semibold flex items-center justify-between group">
                        <span className="text-gray-900 dark:text-white">{menu}</span>
                        <span className="text-xs text-gold group-hover:translate-x-1 transition-transform">Seleccionar →</span>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {selectedEvent.tipo === 'evento' && !isPast && (
                <div className="flex gap-2">
                  {!attending ? <Button onClick={() => handleJoin(selectedEvent)} className="flex-1 !py-3"><UserPlus size={16} /> Apuntar-me a l'esdeveniment</Button> : <Button variant="danger" onClick={() => handleLeave(selectedEvent)} className="flex-1 !py-3"><UserMinus size={16} /> Desapuntar-me</Button>}
                </div>
              )}

              {selectedEvent.tipo === 'comida' && attending && !isPast && (
                <div className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-950/30 rounded-xl border border-green-100 dark:border-green-900/30">
                  <div><span className="text-xs text-green-600 dark:text-green-400 font-bold block">✓ Assistència Confirmada</span><span className="text-sm font-semibold text-gray-800 dark:text-gray-200">Menú: {myAttendance?.menu_elegido}</span></div>
                  <Button variant="danger" size="sm" onClick={() => handleLeave(selectedEvent)}><UserMinus size={14} /></Button>
                </div>
              )}

              {attending && !isPast && <button onClick={() => setShowAddGuest(true)} className="w-full py-2.5 px-4 rounded-xl border-2 border-dashed border-gray-200 dark:border-gray-700 hover:border-gold text-xs font-bold text-gray-500 hover:text-gold transition-colors flex items-center justify-center gap-1.5"><UserPlus size={14} /> Afegir Convidat o Fill/a</button>}

              {myGuests.length > 0 && (
                <div className="space-y-2">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Els meus acompanyants:</p>
                  <div className="space-y-1.5">
                    {myGuests.map(g => (
                      <div key={g.id} className="flex items-center justify-between bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-xl p-2.5 shadow-sm">
                        <div className="flex items-center gap-2"><div className="w-1.5 h-1.5 rounded-full bg-gold" /><span className="text-sm font-bold text-gray-900 dark:text-white">{g.nombre_invitado || g.nombre_hijo}</span><Badge variant={g.es_hijo ? 'blue' : 'gray'} className="text-[10px]">{g.es_hijo ? 'Fill/a' : 'Convidat'}</Badge>{g.menu_elegido && <span className="text-xs text-gray-400 font-medium">({g.menu_elegido})</span>}</div>
                        {!isPast && <button onClick={() => handleRemoveGuest(g.id, selectedEvent)} className="p-1 text-gray-400 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {selectedEvent.tipo === 'comida' && attending && (!myAttendance?.valoracion_comida || editingRating) && (
                <div className="bg-gold/5 border border-gold/20 rounded-2xl p-4 space-y-3">
                  <div className="flex items-center justify-between"><p className="text-xs font-bold text-gold uppercase tracking-wider">{editingRating ? 'Canviar valoració' : 'Què et sembla el menú?'}</p>{editingRating && <button onClick={() => { setEditingRating(false); setRating(0); setComment(''); }} className="text-[11px] font-bold text-gray-400 hover:text-gray-600 transition-colors">Cancel·lar</button>}</div>
                  <div className="flex gap-1.5">{[1, 2, 3, 4, 5].map(s => (<button key={s} onClick={() => setRating(s)} className="hover:scale-110 transition-transform"><Star size={26} className={s <= rating ? 'text-gold fill-gold' : 'text-gray-300 dark:text-gray-600'} /></button>))}</div>
                  <Textarea value={comment} onChange={e => setComment(e.target.value)} placeholder="Deixa un comentari sobre el menú..." />
                  <Button size="sm" onClick={() => { handleRate(selectedEvent); setEditingRating(false); }} disabled={rating === 0}>{editingRating ? 'Actualitzar Valoració' : 'Enviar Valoració'}</Button>
                </div>
              )}

              {myAttendance?.valoracion_comida && !editingRating && (
                <div className="bg-gold/5 rounded-2xl p-4 border border-gold/20 space-y-1.5">
                  <div className="flex items-center justify-between"><p className="text-[11px] font-bold text-gold uppercase tracking-wider">La meua valoració</p><button onClick={() => { setEditingRating(true); setRating(myAttendance.valoracion_comida!); setComment(myAttendance.comentario || ''); }} className="text-[11px] font-bold text-gold hover:text-gold-dark transition-colors">Canviar ✎</button></div>
                  <div className="flex items-center gap-2"><div className="flex gap-0.5">{[1,2,3,4,5].map(s => (<Star key={s} size={16} className={s <= myAttendance.valoracion_comida! ? 'text-gold fill-gold' : 'text-gray-300'} />))}</div><span className="text-xs font-black text-gold">{myAttendance.valoracion_comida}/5</span></div>
                  {myAttendance.comentario && <p className="text-sm text-gray-600 dark:text-gray-300 italic leading-relaxed">"{myAttendance.comentario}"</p>}
                </div>
              )}

              {selectedEvent.tipo === 'comida' && (() => {
                const allReviews = attendees.filter(a => a.valoracion_comida && a.id !== myAttendance?.id);
                if (allReviews.length === 0) return null;
                const avgRating = attendees.filter(a => a.valoracion_comida).reduce((sum, a) => sum + (a.valoracion_comida || 0), 0) / attendees.filter(a => a.valoracion_comida).length;
                return (
                  <div className="space-y-3 pt-2">
                    <div className="flex items-center justify-between"><p className="text-xs font-bold text-gray-500 uppercase tracking-wider flex items-center gap-1.5"><Star size={12} className="text-gold" /> Opinions sobre el menú</p><div className="flex items-center gap-1.5 bg-gold/10 px-2 py-0.5 rounded-full"><Star size={11} className="text-gold fill-gold" /><span className="text-xs font-black text-gold">{avgRating.toFixed(1)}</span><span className="text-[10px] text-gray-400">({attendees.filter(a => a.valoracion_comida).length})</span></div></div>
                    <div className="space-y-2 max-h-48 overflow-y-auto">
                      {allReviews.map(a => {
                        const reviewerName = allUsers.find(u => u.id === a.user_id);
                        return (<div key={a.id} className="bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-xl p-3"><div className="flex items-center justify-between mb-1.5"><span className="text-xs font-bold text-gray-800 dark:text-gray-200">{reviewerName ? reviewerName.nombre : `Membre #${a.user_id}`}</span><div className="flex gap-0.5">{[1,2,3,4,5].map(s => (<Star key={s} size={10} className={s <= (a.valoracion_comida || 0) ? 'text-gold fill-gold' : 'text-gray-200 dark:text-gray-700'} />))}</div></div>{a.comentario && <p className="text-xs text-gray-500 dark:text-gray-400 italic leading-relaxed">"{a.comentario}"</p>}{a.menu_elegido && <p className="text-[10px] text-gold-dark dark:text-gold font-medium mt-1">🍽️ {a.menu_elegido}</p>}</div>);
                      })}
                    </div>
                  </div>
                );
              })()}

              <div className="space-y-2 pt-2">
                <p className="text-xs font-bold text-gray-500 uppercase tracking-wider flex items-center gap-1.5"><Users size={12} /> Assistents ({attendees.length})</p>
                {attendees.length === 0 ? <p className="text-xs text-gray-400 italic">Encara no hi ha assistents confirmats.</p> : <div className="space-y-2 max-h-60 overflow-y-auto pr-1">{attendees.map(a => { const memberName = allUsers.find(u => u.id === a.user_id); const invitedByName = a.invitado_de ? allUsers.find(u => u.id === a.invitado_de) : null; return (<div key={a.id} className="bg-gray-50 dark:bg-gray-800/40 rounded-xl p-2.5 border border-light-border dark:border-dark-border"><div className="flex items-center gap-2 flex-wrap"><div className="w-1.5 h-1.5 bg-green-500 rounded-full shrink-0" /><span className="text-sm font-bold text-gray-900 dark:text-white">{a.es_invitado ? a.nombre_invitado : (a.es_hijo ? a.nombre_hijo : (memberName ? `${memberName.nombre} ${memberName.apellidos}` : `Membre #${a.user_id}`))}</span>{!a.es_invitado && !a.es_hijo && <Badge variant="red" className="text-[9px]">Membre</Badge>}{a.es_invitado && <Badge variant="gray" className="text-[9px]">Convidat</Badge>}{a.es_hijo && <Badge variant="blue" className="text-[9px]">Fill/a</Badge>}</div><div className="flex flex-wrap gap-x-3 gap-y-1 mt-1 ml-3.5 text-[11px] text-gray-500">{(a.es_invitado || a.es_hijo) && invitedByName && (<span className="font-medium text-gray-400">👤 De: {invitedByName.nombre}</span>)}{a.menu_elegido && <span className="text-gold-dark dark:text-gold font-medium">🍽️ {a.menu_elegido}</span>}{a.valoracion_comida && (<span className="text-gold font-bold">⭐ {a.valoracion_comida}/5</span>)}{a.comentario && (<span className="italic text-gray-400">"{a.comentario}"</span>)}</div></div>);})}</div>}
              </div>

              {user?.is_admin && (
                <div className="flex gap-2 pt-3 border-t border-light-border dark:border-dark-border">
                  <Button variant="ghost" size="sm" onClick={() => exportEvent(selectedEvent)} className="flex-1 text-xs"><Download size={14} /> Exportar Excel</Button>
                  <Button variant="danger" size="sm" onClick={() => handleDelete(selectedEvent.id)} className="text-xs"><Trash2 size={14} /> Eliminar</Button>
                </div>
              )}
            </div>
          );
        })()}
      </Modal>

      {/* Add Guest Modal */}
      <Modal open={showAddGuest} onClose={() => setShowAddGuest(false)} title="Afegir Convidat o Fill/a">
        <div className="space-y-4">
          <Input label="Nom complet" value={guestName} onChange={e => setGuestName(e.target.value)} placeholder="Nom de l'acompanyant" />
          <div className="flex items-center gap-3"><input type="checkbox" checked={isChild} onChange={e => setIsChild(e.target.checked)} className="w-4 h-4 accent-fila-red" id="isChild" /><label htmlFor="isChild" className="text-sm font-medium text-gray-700 dark:text-gray-300">És el meu fill/a</label></div>
          {selectedEvent?.tipo === 'comida' && selectedEvent.opciones_menu && (<Select label="Menú" value={guestMenu} onChange={e => setGuestMenu(e.target.value)} options={[{ value: '', label: 'Selecciona el menú' }, ...selectedEvent.opciones_menu.map(m => ({ value: m, label: m })),]} />)}
          <Button onClick={() => selectedEvent && handleAddGuest(selectedEvent)} className="w-full !py-3">Confirmar Acompanyant</Button>
        </div>
      </Modal>

      {/* Create Event Modal */}
      <Modal open={showNew} onClose={() => setShowNew(false)} title="Nou Esdeveniment">
        <div className="space-y-4">
          <Select label="Tipus d'esdeveniment" value={tipo} onChange={e => setTipo(e.target.value as 'evento' | 'comida')} options={[{ value: 'evento', label: 'Esdeveniment / Festa' }, { value: 'comida', label: 'Menjar / Dinar / Sopar' },]} />
          <Input label="Títol" value={titulo} onChange={e => setTitulo(e.target.value)} placeholder="Nom de l'esdeveniment" />
          <Textarea label="Descripció" value={desc} onChange={e => setDesc(e.target.value)} placeholder="Descriu l'esdeveniment..." />
          <div className="grid grid-cols-2 gap-3"><Input label="Data" type="date" value={fecha} onChange={e => setFecha(e.target.value)} min={today} /><Input label="Hora" type="time" value={hora} onChange={e => setHora(e.target.value)} /></div>
          {tipo === 'evento' && (<Input label="Codi de vestimenta" value={vestimenta} onChange={e => setVestimenta(e.target.value)} placeholder="Ex: Vestit oficial de la Filà" />)}
          {tipo === 'comida' && (<div><label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Opcions de menú</label>{menuOptions.map((m, i) => (<div key={i} className="flex gap-2 mb-2"><Input value={m} onChange={e => { const n = [...menuOptions]; n[i] = e.target.value; setMenuOptions(n); }} placeholder={`Menú ${i + 1}`} />{menuOptions.length > 2 && (<button onClick={() => setMenuOptions(menuOptions.filter((_, j) => j !== i))} className="text-red-400"><Trash2 size={16} /></button>)}</div>))}<button onClick={() => setMenuOptions([...menuOptions, ''])} className="text-xs font-bold text-fila-red hover:underline block mt-1">+ Afegir opció de menú</button></div>)}
          <Button onClick={handleCreate} className="w-full">Crear Esdeveniment</Button>
        </div>
      </Modal>
    </div>
  );
}
