import { supabase } from '../lib/supabase';
import type { Announcement, Vote, VoteResponse, Event, EventAttendee, Order, OrderResponse } from '../types';

export const dataStore = {
  // Announcements
  getAnnouncements: async (): Promise<Announcement[]> => {
    const { data, error } = await supabase
      .from('announcements')
      .select('*')
      .gte('expires_at', new Date().toISOString().split('T')[0])
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data || [];
  },
  addAnnouncement: async (a: Omit<Announcement, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('announcements')
      .insert([a])
      .select()
      .single();
    if (error) throw error;
    return data;
  },
  deleteAnnouncement: async (id: string) => {
    const { error } = await supabase
      .from('announcements')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },

  // Votes
  getVotes: async (): Promise<Vote[]> => {
    const limit = new Date();
    limit.setDate(limit.getDate() - 5);
    const { data, error } = await supabase
      .from('votes')
      .select('*')
      .gte('fecha_cierre', limit.toISOString().split('T')[0])
      .order('fecha_cierre', { ascending: true });
    
    if (error) throw error;
    return data || [];
  },
  addVote: async (v: Omit<Vote, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('votes')
      .insert([v])
      .select()
      .single();
    if (error) throw error;
    return data;
  },
  deleteVote: async (id: string) => {
    const { error } = await supabase
      .from('votes')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
  getVoteResponses: async (voteId: string): Promise<VoteResponse[]> => {
    const { data, error } = await supabase
      .from('vote_responses')
      .select('*')
      .eq('vote_id', voteId);
    if (error) throw error;
    return data || [];
  },
  addVoteResponse: async (vr: Omit<VoteResponse, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('vote_responses')
      .upsert([vr], { onConflict: 'vote_id,user_id' })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // Events
  getEvents: async (): Promise<Event[]> => {
    const { data, error } = await supabase
      .from('events')
      .select('*')
      .order('fecha_evento', { ascending: true });
    if (error) throw error;
    return data || [];
  },
  getUpcomingEvents: async (limitCount = 5): Promise<Event[]> => {
    const { data, error } = await supabase
      .from('events')
      .select('*')
      .gte('fecha_evento', new Date().toISOString().split('T')[0])
      .order('fecha_evento', { ascending: true })
      .limit(limitCount);
    if (error) throw error;
    return data || [];
  },
  addEvent: async (e: Omit<Event, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('events')
      .insert([e])
      .select()
      .single();
    if (error) throw error;
    return data;
  },
  deleteEvent: async (id: string) => {
    const { error } = await supabase
      .from('events')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
  getEventAttendees: async (eventId: string): Promise<EventAttendee[]> => {
    const { data, error } = await supabase
      .from('event_attendees')
      .select('*')
      .eq('event_id', eventId);
    if (error) throw error;
    return data || [];
  },
  addEventAttendee: async (ea: Omit<EventAttendee, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('event_attendees')
      .insert([ea])
      .select()
      .single();
    if (error) throw error;
    return data;
  },
  removeEventAttendee: async (id: string) => {
    const { error } = await supabase
      .from('event_attendees')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
  updateEventAttendee: async (id: string, updates: Partial<EventAttendee>) => {
    const { data, error } = await supabase
      .from('event_attendees')
      .update(updates)
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // Orders
  getOrders: async (): Promise<Order[]> => {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .order('fecha_cierre', { ascending: true });
    if (error) throw error;
    return data || [];
  },
  addOrder: async (o: Omit<Order, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('orders')
      .insert([o])
      .select()
      .single();
    if (error) throw error;
    return data;
  },
  deleteOrder: async (id: string) => {
    const { error } = await supabase
      .from('orders')
      .delete()
      .eq('id', id);
    if (error) throw error;
  },
  getOrderResponses: async (orderId: string): Promise<OrderResponse[]> => {
    const { data, error } = await supabase
      .from('order_responses')
      .select('*')
      .eq('order_id', orderId);
    if (error) throw error;
    return data || [];
  },
  addOrderResponse: async (or: Omit<OrderResponse, 'id' | 'created_at'>) => {
    const { data, error } = await supabase
      .from('order_responses')
      .upsert([or], { onConflict: 'order_id,user_id' })
      .select()
      .single();
    if (error) throw error;
    return data;
  },

  // Users Helper
  getAllUsers: async (): Promise<any[]> => {
    const { data, error } = await supabase
      .from('users')
      .select('id, nombre, apellidos');
    if (error) throw error;
    return data || [];
  }
};
