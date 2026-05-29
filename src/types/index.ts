export type UserType = 'nino' | 'joven' | 'adulto';
export type CuotaType = 'basica' | 'full' | 'joven';
export type EventType = 'evento' | 'comida';

export interface User {
  id: string;
  email: string;
  nombre: string;
  apellidos: string;
  fecha_nacimiento: string;
  tipo_usuario: UserType;
  tipo_cuota: CuotaType;
  telefono: string;
  foto_url?: string;
  is_admin: boolean;
  created_at: string;
}

export interface Announcement {
  id: string;
  titulo: string;
  mensaje: string;
  created_by: string;
  created_at: string;
  expires_at: string;
  is_birthday: boolean;
  author?: User;
}

export interface Vote {
  id: string;
  titulo: string;
  descripcion: string;
  opciones: string[];
  multiple: boolean;
  fecha_cierre: string;
  created_by: string;
  created_at: string;
  author?: User;
}

export interface VoteResponse {
  id: string;
  vote_id: string;
  user_id: string;
  opciones_elegidas: string[];
  created_at: string;
  user?: User;
}

export interface Event {
  id: string;
  tipo: EventType;
  titulo: string;
  descripcion: string;
  fecha_evento: string;
  hora_evento?: string;
  codigo_vestimenta?: string;
  opciones_menu?: string[];
  created_by: string;
  created_at: string;
  author?: User;
}

export interface EventAttendee {
  id: string;
  event_id: string;
  user_id: string;
  menu_elegido?: string;
  es_invitado: boolean;
  nombre_invitado?: string;
  invitado_de?: string;
  es_hijo: boolean;
  nombre_hijo?: string;
  valoracion_comida?: number;
  comentario?: string;
  created_at: string;
  user?: User;
}

export interface Order {
  id: string;
  titulo: string;
  descripcion: string;
  items: OrderItem[];
  fecha_cierre: string;
  created_by: string;
  created_at: string;
  author?: User;
}

export interface OrderItem {
  nombre: string;
  tallas?: string[];
  precio?: number;
}

export interface OrderResponse {
  id: string;
  order_id: string;
  user_id: string;
  items: OrderResponseItem[];
  created_at: string;
  user?: User;
}

export interface OrderResponseItem {
  nombre: string;
  talla?: string;
  cantidad: number;
}
