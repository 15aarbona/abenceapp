import { useState, useEffect } from 'react';
import { ShoppingBag, Plus, Trash2, Download, Clock, Package } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { dataStore } from '../store/dataStore';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input, Textarea, Select } from '../components/ui/Input';
import type { Order, OrderItem, OrderResponseItem, User, OrderResponse } from '../types';
import * as XLSX from 'xlsx';

export function OrdersPage() {
  const { user } = useAuth();
  const [orders, setOrders] = useState<Order[]>([]);
  const [allUsers, setAllUsers] = useState<User[]>([]);
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [orderResponses, setOrderResponses] = useState<OrderResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [showNew, setShowNew] = useState(false);

  // Form state
  const [titulo, setTitulo] = useState('');
  const [desc, setDesc] = useState('');
  const [closeDate, setCloseDate] = useState('');
  const [items, setItems] = useState<OrderItem[]>([{ nombre: '', tallas: [], precio: 0 }]);
  const [tallasInput, setTallasInput] = useState<string[]>(['S,M,L,XL,XXL']);

  // Response state
  const [myItems, setMyItems] = useState<OrderResponseItem[]>([]);

  const today = new Date().toISOString().split('T')[0];

  useEffect(() => {
    fetchOrders();
    fetchAllUsers();
  }, []);

  const fetchOrders = async () => {
    setLoading(true);
    try {
      const data = await dataStore.getOrders();
      setOrders(data);
    } catch (error) {
      console.error('Error fetching orders:', error);
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

  const fetchResponses = async (orderId: string) => {
    try {
      const data = await dataStore.getOrderResponses(orderId);
      setOrderResponses(data);
    } catch (error) {
      console.error('Error fetching responses:', error);
    }
  };

  const isOpen = (order: Order) => order.fecha_cierre >= today;

  const handleCreate = async () => {
    if (!titulo.trim() || !closeDate) return;
    const parsedItems: OrderItem[] = items
      .filter(i => i.nombre.trim())
      .map((item, idx) => ({
        nombre: item.nombre,
        tallas: tallasInput[idx]?.split(',').map(t => t.trim()).filter(Boolean) || [],
        precio: item.precio,
      }));
    
    try {
      await dataStore.addOrder({
        titulo,
        descripcion: desc,
        items: parsedItems,
        fecha_cierre: closeDate,
        created_by: user!.id,
      });
      fetchOrders();
      setTitulo(''); setDesc(''); setCloseDate('');
      setItems([{ nombre: '', tallas: [], precio: 0 }]);
      setTallasInput(['S,M,L,XL,XXL']);
      setShowNew(false);
    } catch (error) {
      console.error('Error creating order:', error);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      await dataStore.deleteOrder(id);
      fetchOrders();
      setSelectedOrder(null);
    } catch (error) {
      console.error('Error deleting order:', error);
    }
  };

  const handleSelectOrder = async (order: Order) => {
    setSelectedOrder(order);
    await fetchResponses(order.id);
    const existing = orderResponses.find(r => r.user_id === user?.id);
    if (existing) {
      setMyItems(existing.items);
    } else {
      setMyItems(order.items.map(i => ({ nombre: i.nombre, talla: i.tallas?.[0] || '', cantidad: 0 })));
    }
  };

  const handleSubmitOrder = async () => {
    if (!selectedOrder) return;
    const filtered = myItems.filter(i => i.cantidad > 0);
    if (filtered.length === 0) return;
    try {
      await dataStore.addOrderResponse({
        order_id: selectedOrder.id,
        user_id: user!.id,
        items: filtered,
      });
      fetchResponses(selectedOrder.id);
      fetchOrders();
    } catch (error) {
      console.error('Error submitting order:', error);
    }
  };

  const exportOrder = (order: Order) => {
    const rows: Record<string, string | number>[] = [];
    orderResponses.forEach(r => {
      const userName = allUsers.find(u => u.id === r.user_id);
      r.items.forEach(item => {
        rows.push({
          'Usuari': userName ? `${userName.nombre} ${userName.apellidos}` : `Membre #${r.user_id}`,
          'Article': item.nombre,
          'Talla': item.talla || '-',
          'Quantitat': item.cantidad,
        });
      });
    });
    const ws = XLSX.utils.json_to_sheet(rows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Comandes');
    XLSX.writeFile(wb, `comanda_${order.titulo.replace(/\s+/g, '_')}.xlsx`);
  };

  const formatDate = (d: string) => new Date(d + 'T00:00:00').toLocaleDateString('ca-ES', { day: 'numeric', month: 'short', year: 'numeric' });

  const getMyResponse = () => {
    return orderResponses.find(r => r.user_id === user?.id);
  };

  if (loading && orders.length === 0) {
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
          <p className="text-xs font-semibold text-gold tracking-widest uppercase">Equipament</p>
          <h2 className="text-2xl font-black text-gray-900 dark:text-white tracking-tight">Comandes</h2>
        </div>
        {user?.is_admin && <Button size="sm" onClick={() => setShowNew(true)}><Plus size={16} /> Nova</Button>}
      </div>

      {orders.length === 0 ? (
        <div className="bg-white/40 dark:bg-dark-card/40 backdrop-blur-sm border border-light-border dark:border-dark-border rounded-3xl p-12 text-center">
          <ShoppingBag size={40} className="mx-auto text-gray-300 dark:text-gray-600 mb-3" />
          <p className="text-gray-400 font-medium">No hi ha cap full de comanda actiu</p>
        </div>
      ) : (
        <div className="space-y-3.5">
          {orders.map(order => {
            const open = isOpen(order);
            return (
              <div 
                key={order.id} 
                onClick={() => handleSelectOrder(order)}
                className="bg-white dark:bg-dark-card border border-light-border dark:border-dark-border rounded-2xl p-5 shadow-sm hover:shadow-md transition-all cursor-pointer relative overflow-hidden group"
              >
                <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-gold to-gold-dark" />
                <div className="flex gap-4">
                  <div className="w-12 h-12 rounded-xl bg-gradient-to-tr from-gold/20 to-gold/5 text-gold flex items-center justify-center shrink-0">
                    <Package size={24} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2 mb-1">
                      <h4 className="font-bold text-gray-900 dark:text-white text-base group-hover:text-gold transition-colors">{order.titulo}</h4>
                      {open ? <Badge variant="green">Obert</Badge> : <Badge variant="gray">Tancat</Badge>}
                    </div>
                    <p className="text-sm text-gray-500 line-clamp-2 mb-3">{order.descripcion}</p>
                    <div className="flex items-center justify-between pt-2 border-t border-light-border dark:border-dark-border">
                      <div className="flex items-center gap-3 text-xs text-gray-400 font-medium">
                        <span className="flex items-center gap-1"><Clock size={12} className="text-gold" /> Tanca: {formatDate(order.fecha_cierre)}</span>
                      </div>
                      <span className="text-xs font-bold text-gray-400 group-hover:text-gray-900 dark:group-hover:text-white transition-colors">Fer comanda →</span>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Order Detail Modal */}
      <Modal open={!!selectedOrder} onClose={() => { setSelectedOrder(null); setOrderResponses([]); }} title={selectedOrder?.titulo || ''}>
        {selectedOrder && (() => {
          const open = isOpen(selectedOrder);
          const myResp = getMyResponse();
          return (
            <div className="space-y-5">
              <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed">{selectedOrder.descripcion}</p>
              <div className="flex gap-2">
                {open ? <Badge variant="green">Obert per a comandes</Badge> : <Badge variant="gray">Tancat</Badge>}
                <Badge variant="gray">Tanca: {formatDate(selectedOrder.fecha_cierre)}</Badge>
              </div>
              <div className="space-y-3 pt-1">
                <p className="text-xs font-bold text-gray-500 uppercase tracking-wider">Llista d'articles disponibles:</p>
                {selectedOrder.items.map((item, idx) => (
                  <div key={idx} className="bg-gray-50 dark:bg-gray-800/40 border border-light-border dark:border-dark-border rounded-xl p-4">
                    <div className="flex items-center justify-between mb-2.5">
                      <span className="font-bold text-gray-900 dark:text-white text-sm">{item.nombre}</span>
                      {item.precio !== undefined && item.precio > 0 && <span className="text-sm text-gold font-black bg-gold/10 px-2 py-0.5 rounded-md">{item.precio}€</span>}
                    </div>
                    {open && (
                      <div className="flex gap-3 items-end pt-1">
                        {item.tallas && item.tallas.length > 0 && (<div className="flex-1"><Select label="Talla" value={myItems[idx]?.talla || ''} onChange={e => { const updated = [...myItems]; if (updated[idx]) updated[idx] = { ...updated[idx], talla: e.target.value }; setMyItems(updated); }} options={item.tallas.map(t => ({ value: t, label: t }))} /></div>)}
                        <div className="w-24"><Input label="Quantitat" type="number" min="0" value={String(myItems[idx]?.cantidad || 0)} onChange={e => { const updated = [...myItems]; if (updated[idx]) updated[idx] = { ...updated[idx], cantidad: Number(e.target.value) }; setMyItems(updated); }} /></div>
                      </div>
                    )}
                    {!open && myResp && (
                      <div className="pt-2 border-t border-light-border dark:border-dark-border mt-2 text-xs text-gray-500">
                        {myResp.items.filter(i => i.nombre === item.nombre).map(i => (<span key={i.nombre} className="font-semibold text-gray-700 dark:text-gray-300">Talla sol·licitada: <strong className="text-gold">{i.talla || 'Única'}</strong> · Quantitat: <strong>{i.cantidad}</strong></span>))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
              {open && (() => {
                const total = myItems.reduce((sum, item, idx) => { const price = selectedOrder.items[idx]?.precio || 0; return sum + (price * (item.cantidad || 0)); }, 0);
                return total > 0 ? (<div className="bg-gradient-to-r from-gold/10 via-gold/5 to-transparent border-l-4 border-gold rounded-r-xl p-3 flex items-center justify-between"><span className="text-xs font-bold text-gray-600 dark:text-gray-400 uppercase tracking-wider">Total estimat: </span><span className="text-xl font-black text-gold">{total}€</span></div>) : null;
              })()}
              {open && <div className="pt-2"><Button onClick={handleSubmitOrder} className="w-full !py-3">{myResp ? 'Actualitzar la meua comanda' : 'Enviar Comanda'}</Button></div>}
              {myResp && <div className="bg-green-50 dark:bg-green-950/30 rounded-xl p-3 border border-green-100 dark:border-green-900/30 text-center"><p className="text-xs text-green-600 dark:text-green-400 font-bold">✓ Comanda registrada correctament</p></div>}
              {user?.is_admin && (
                <div className="flex gap-2 pt-3 border-t border-light-border dark:border-dark-border">
                  <Button variant="ghost" size="sm" onClick={() => exportOrder(selectedOrder)} className="flex-1 text-xs"><Download size={14} /> Exportar Excel</Button>
                  <Button variant="danger" size="sm" onClick={() => handleDelete(selectedOrder.id)} className="text-xs"><Trash2 size={14} /> Eliminar</Button>
                </div>
              )}
            </div>
          );
        })()}
      </Modal>

      {/* Create Order Modal */}
      <Modal open={showNew} onClose={() => setShowNew(false)} title="Nou Full de Comanda">
        <div className="space-y-4">
          <Input label="Títol" value={titulo} onChange={e => setTitulo(e.target.value)} placeholder="Ex: Samarretes Festes 2025" />
          <Textarea label="Descripció" value={desc} onChange={e => setDesc(e.target.value)} placeholder="Descriu la comanda..." />
          <Input label="Data de tancament" type="date" value={closeDate} onChange={e => setCloseDate(e.target.value)} min={today} />
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Articles</label>
            {items.map((item, i) => (
              <div key={i} className="space-y-2 mb-4 bg-gray-50 dark:bg-gray-800/40 rounded-xl p-3 border border-light-border dark:border-dark-border">
                <Input placeholder="Nom de l'article" value={item.nombre} onChange={e => { const n = [...items]; n[i] = { ...n[i], nombre: e.target.value }; setItems(n); }} />
                <Input placeholder="Talles (separades per coma): S,M,L,XL" value={tallasInput[i] || ''} onChange={e => { const n = [...tallasInput]; n[i] = e.target.value; setTallasInput(n); }} />
                <Input type="number" placeholder="Preu (€)" value={String(item.precio || '')} onChange={e => { const n = [...items]; n[i] = { ...n[i], precio: Number(e.target.value) }; setItems(n); }} />
                {items.length > 1 && <button onClick={() => { setItems(items.filter((_, j) => j !== i)); setTallasInput(tallasInput.filter((_, j) => j !== i)); }} className="text-xs text-red-400 hover:text-red-600 font-bold">Eliminar article</button>}
              </div>
            ))}
            <button onClick={() => { setItems([...items, { nombre: '', tallas: [], precio: 0 }]); setTallasInput([...tallasInput, 'S,M,L,XL,XXL']); }} className="text-xs font-bold text-fila-red hover:underline block mt-1">+ Afegir article</button>
          </div>
          <Button onClick={handleCreate} className="w-full">Crear Full de Comanda</Button>
        </div>
      </Modal>
    </div>
  );
}
