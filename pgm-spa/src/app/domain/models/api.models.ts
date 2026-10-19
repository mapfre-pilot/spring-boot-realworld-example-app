/** Modelos alineados con el contrato OpenAPI del BFF (pgm-bff/sources/src/main/resources/openapi/pgm-bff.yaml). */
export type Tipologia = 'PARTICULAR' | 'AUTONOMO' | 'EMPRESA';
export type EstadoCliente = 'EN_VIGOR' | 'POTENCIAL' | 'ANULADO';
export type Ramo =
  'AUTOS' | 'HOGAR' | 'SALUD' | 'VIDA' | 'DECESOS' | 'AHORRO' | 'EMPRESAS' | 'OTROS';
export const RAMOS: Ramo[] = [
  'AUTOS',
  'HOGAR',
  'SALUD',
  'VIDA',
  'DECESOS',
  'AHORRO',
  'EMPRESAS',
  'OTROS',
];

export interface Lista<T> {
  items: T[];
  total: number;
}

export interface EstructuraComercial {
  nuuma: string;
  oficina: string;
  delegacion: string;
  territorial: string;
}

export interface ContextoUsuario {
  usuario: string;
  nombre: string;
  perfiles: string[];
  perfilSgc30: string | null;
  estructura: EstructuraComercial | null;
  visibilidades: Record<string, boolean>;
}

export const Visibilidad = {
  INICIO: 'inicio',
  FICHA_CLIENTE: 'fichaCliente',
  NUEVA_PRODUCCION: 'nuevaProduccion',
  GESTION_CARTERA: 'gestionCartera',
  RECIBOS: 'recibos',
  PRESTACIONES: 'prestaciones',
  GESTION_COMERCIAL: 'gestionComercial',
  GESTIONES_SGC30: 'gestionesSgc30',
  ACTIVIDAD_COMERCIAL: 'actividadComercial',
  ANADIR_VENCIMIENTO: 'anadirVencimiento',
  UTILIDADES: 'utilidades',
  CUADRO_MANDO: 'cuadroMando',
  TARIFICACION_SALUD: 'tarificacionSalud',
} as const;
export type VisibilidadKey = (typeof Visibilidad)[keyof typeof Visibilidad];

export interface CriteriosBusqueda {
  texto?: string;
  documento?: string;
  telefono?: string;
  email?: string;
  poliza?: string;
  tarjetaSanitaria?: string;
  localidad?: string;
}

export interface ClienteResumen {
  id: string;
  nombre: string;
  apellidos: string;
  tipoDocumento: string;
  documento: string;
  tipologia: Tipologia;
  estado: EstadoCliente;
  telefono: string;
  email: string;
  localidad: string;
  numeroPolizasEnVigor: number;
}

export interface Direccion {
  via: string;
  numero: string;
  codigoPostal: string;
  localidad: string;
  provincia: string;
}

export interface Palancas {
  dniDigitalizado: boolean;
  rgpdFirmado: boolean;
  altaAci: boolean;
  clienteTotal: boolean;
  planPagos: boolean;
  enFamilia: boolean;
  dpv: boolean;
}

export interface Alerta {
  tipo: string;
  texto: string;
  fecha: string;
}

export interface MiembroFamilia {
  clienteId: string;
  nombre: string;
  parentesco: string;
}

export interface Cliente {
  id: string;
  nombre: string;
  apellidos: string;
  tipoDocumento: string;
  documento: string;
  fechaNacimiento: string | null;
  nacionalidad: string;
  tipologia: Tipologia;
  estado: EstadoCliente;
  vip: boolean;
  robinson: boolean;
  exclusivoCorredor: boolean;
  direccion: Direccion;
  telefono: string;
  email: string;
  oficinaGestora: string;
  gestorAsignado: string;
  palancas: Palancas;
  alertas: Alerta[];
  familia: MiembroFamilia[];
  posicionBancaria: string | null;
  descuentoVinculacion: number | null;
}

export interface Poliza {
  numero: string;
  clienteId: string;
  ramo: Ramo;
  producto: string;
  estado: 'EN_VIGOR' | 'ANULADA' | 'SUSPENDIDA';
  fechaEfecto: string;
  fechaVencimiento: string;
  primaAnual: number;
  formaPago: string;
  riesgo: string;
  acciones: string[];
  lanzadera: string | null;
}

export interface Recibo {
  numero: string;
  clienteId: string;
  polizaNumero: string;
  ramo: Ramo;
  estado: 'PENDIENTE' | 'COBRADO' | 'DEVUELTO' | 'ANULADO';
  importe: number;
  fechaEmision: string;
  fechaVencimiento: string;
  formaPago: string;
  ibanEnmascarado: string | null;
}

export interface Prestacion {
  numero: string;
  clienteId: string;
  polizaNumero: string;
  ramo: Ramo;
  tipo: string;
  estado: 'ABIERTA' | 'EN_TRAMITE' | 'CERRADA' | 'RECHAZADA';
  fechaOcurrencia: string;
  fechaApertura: string;
  descripcion: string;
  tramitador: string;
}

export interface Presupuesto {
  numero: string;
  clienteId: string;
  ramo: Ramo;
  producto: string;
  estado: string;
  fecha: string;
  fechaCaducidad: string;
  primaAnual: number;
}

export interface Oportunidad {
  id: string;
  clienteId: string;
  tipo: string;
  ramo: Ramo;
  polizaNumero: string | null;
  fecha: string;
  descripcion: string;
  prioridad: 'ALTA' | 'MEDIA' | 'BAJA';
}

export interface GestionComercial {
  id: string;
  clienteId: string;
  tipo: string;
  estado: string;
  fecha: string;
  descripcion: string;
  gestor: string;
  origen: string;
}

export interface SolicitudSgo {
  id: string;
  clienteId: string;
  tipo: string;
  estado: string;
  fecha: string;
  descripcion: string;
}

export interface Lanzadera {
  codigo: string;
  nombre: string;
  destino: string;
  ramo: Ramo | null;
  url: string;
  requiereNuuma: boolean;
}

export interface Kpi {
  codigo: string;
  nombre: string;
  valor: number;
  unidad: string;
  periodo: string;
}

export interface TarificacionSolicitud {
  clienteId: string;
  producto: string;
  codigoPostal: string;
  edades: number[];
  copago: boolean;
}

export interface TarificacionResultado {
  id: string;
  producto: string;
  primaMensual: number;
  primaAnual: number;
  coberturas: string[];
  estado: string;
}

export interface AuditoriaRequest {
  accion: string;
  clienteId?: string;
  pantalla: string;
}
