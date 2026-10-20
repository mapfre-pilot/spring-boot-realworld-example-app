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
  CONFIGURACION: 'configuracion',
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
  primerApellido?: string;
  segundoApellido?: string;
  codigoPostal?: string;
  expediente?: string;
  matricula?: string;
  presupuesto?: string;
  recibo?: string;
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
  fechaNacimiento: string | null;
  domicilio: string | null;
  codigoPostal: string | null;
  robinson: boolean;
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

/** Fila de «Vencimientos» de PGM: Producto/Riesgo, Venc./Oport., Anexos, Usuario, Entidad competencia, F. Venci./Opor., Prima/Saldo, Comentarios, Clase de Vcto. */
export interface Oportunidad {
  id: string;
  clienteId: string;
  tipo: 'VENCIMIENTO' | 'OPORTUNIDAD' | 'CROSSELLING';
  ramo: Ramo;
  polizaNumero: string | null;
  fecha: string;
  descripcion: string;
  prioridad: 'ALTA' | 'MEDIA' | 'BAJA';
  clase: 'COMPLETO' | 'INCOMPLETO' | 'PRECOTIZADO' | null;
  usuario: string | null;
  entidadCompetencia: string | null;
  prima: number | null;
  comentarios: string | null;
  anexos: number;
  contratado: boolean;
}

export interface ResumenOportunidades {
  todos: number;
  completos: number;
  incompletos: number;
  presupuestos: number;
}

export interface Observacion {
  id: string;
  fecha: string;
  fechaActualizacion: string | null;
  texto: string;
  usuario: string;
}

export interface DocumentoAdjunto {
  id: string;
  nombre: string;
  tipo: string;
  fecha: string;
  usuario: string;
}

export interface OportunidadDetalle {
  oportunidad: Oportunidad;
  datosGenerales: Record<string, string>;
  datosProducto: Record<string, string>;
  datosRiesgo: Record<string, string>;
  observaciones: Observacion[];
  documentos: DocumentoAdjunto[];
}

export interface AltaOportunidad {
  ramo: Ramo;
  tipo?: Oportunidad['tipo'];
  fecha: string;
  entidadCompetencia?: string;
  prima?: number | null;
  comentarios?: string;
  datosProducto?: Record<string, string>;
  datosRiesgo?: Record<string, string>;
}

export interface FiltroOportunidades {
  producto?: Ramo | null;
  tipo?: Oportunidad['tipo'] | null;
  clase?: Oportunidad['clase'];
  desde?: string | null;
  hasta?: string | null;
  contratado?: boolean | null;
}

/** Diario de actividad comercial iMediador: Fecha y hora, Gestión Alcanzada, Usuario, Acción, Tipo de acción, Comentarios, Producto, Prima. */
export interface ActividadComercial {
  id: string;
  clienteId: string;
  fecha: string;
  gestionAlcanzada: string;
  usuario: string;
  accion: string;
  tipoAccion: string;
  comentarios: string | null;
  producto: string | null;
  prima: number | null;
}

export interface FiltroActividad {
  desde?: string | null;
  hasta?: string | null;
  gestionAlcanzada?: string | null;
  producto?: string | null;
  tipoAccion?: string | null;
}

export interface AltaActividad {
  nivelGestion: string;
  comentario?: string;
  polizaNumero?: string | null;
  sinRgpd?: boolean;
}

export interface CatalogoItem {
  codigo: string;
  nombre: string;
}
export type TipoCatalogoComercial = 'ACCIONES' | 'NIVELES_GESTION' | 'COMPANIAS';
export interface CatalogoComercial {
  tipo: TipoCatalogoComercial;
  items: CatalogoItem[];
}

/** Gestión SGC 3.0: F. caducidad, Acci. Comercial (+WhatsApp), Comentarios, Prob., Estado, Agendado, Usuario. */
export interface GestionComercial {
  id: string;
  clienteId: string;
  tipo: string;
  estado: 'ABIERTA' | 'CERRADA_POSITIVA' | 'CERRADA_NEGATIVA' | 'CADUCADA' | string;
  fecha: string;
  descripcion: string;
  gestor: string;
  origen: string;
  fechaCaducidad: string | null;
  probabilidadConversion: number | null;
  agendado: boolean;
  whatsapp: boolean;
  permisos: string[];
}

export interface GestionDetalle {
  gestion: GestionComercial;
  potencialidad: string;
  asignadaA: string | null;
  telefonos: string[];
  email: string | null;
  observaciones: Observacion[];
  documentos: DocumentoAdjunto[];
  gestionesAlcanzadas: ActividadComercial[];
}

export interface SolicitudSgoDetalle {
  solicitud: SolicitudSgo;
  datos: Record<string, string>;
  documentos: DocumentoAdjunto[];
}

export interface BorradorResumen {
  id: string;
  producto: string;
  codigoPostal: string;
  asegurados: number;
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

// ---- Menú ACCIONES y palancas de la cabecera (PGM_Header_AccionesCliente) ----
export interface Telefono {
  tipo: string;
  motivo: string;
  prefijo: string;
  numero: string;
}
export interface MasDatos {
  nacionalidad: string | null;
  idioma: string | null;
  fechaNacimiento: string | null;
  edad: number | null;
  sexo: string | null;
  numeroHijos: number | null;
  tipoPersona: string | null;
  estadoCivil: string | null;
  empleadoMapfre: boolean;
  profesion: string | null;
  telefonos: Telefono[];
  emails: string[];
  origenDatos: Record<string, string>;
  avisos: string[];
}
export interface ContactoActualizado {
  telefonos: Telefono[];
  emails: string[];
}
export interface Interaccion {
  id: string;
  fecha: string;
  canal: string;
  motivo: string;
  descripcion: string;
  estado: string;
}
export type PeriodoComunicaciones = '30D' | '12M' | '3A';
export interface Comunicaciones {
  alertas: Alerta[];
  interacciones: Interaccion[];
  reclamaciones: Interaccion[];
  periodo: PeriodoComunicaciones;
}
export interface DocumentoCliente {
  id: string;
  tipoDocumento: string;
  codificacion: string;
  nombre: string;
  fechaAlta: string;
  fechaVigencia: string | null;
  nivelLopd: string;
  clasificacion: string;
  contrato: string | null;
  clausula: string | null;
}
export interface MetodoFirma {
  codigo: 'BIOMETRICA' | 'EMAIL' | 'SMS' | 'IMPRESION' | string;
  nombre: string;
  disponible: boolean;
}
export interface FirmaRgpd {
  metodos: MetodoFirma[];
  estado: string;
}
export interface ResultadoAccion {
  estado: string;
  mensaje: string;
  referencia: string;
}
export interface EmpresaVinculada {
  cif: string;
  razonSocial: string;
  actividad: string | null;
  segmento: string | null;
  clasificacion: string | null;
  cargo: string | null;
  estado: string | null;
}
export interface ClienteTotal {
  nif: string;
  nombre: string;
  clasificacionActual: string;
  nuevaClasificacion: string | null;
  empresas: EmpresaVinculada[];
  puedeFirmar: boolean;
}
export interface PlanPagos {
  susceptible: boolean;
  individualDisponible: boolean;
  familiarDisponible: boolean;
  mensaje: string | null;
}
export interface SimulacionPlanPagos {
  tipo: 'INDIVIDUAL' | 'FAMILIAR';
  cuotaMensual: number;
  numeroCuotas: number;
  productosIncluidos: string[];
}

// ---- Posición del cliente (área B): acciones/documentos/detalle de póliza, estados anteriores, recibo, prestación ----
export interface AccionPoliza {
  codigo: string;
  nombre: string;
  destino: string;
  url: string | null;
  requiereNuuma: boolean;
  externa: boolean;
}
export interface DocumentoPoliza {
  id: string;
  tipo: string;
  nombre: string;
  fecha: string;
  formato: string;
}
export interface Garantia {
  codigo: string;
  nombre: string;
  capital: number | null;
  franquicia: string | null;
}
export interface Beneficiario {
  nombre: string;
  documento: string;
  parentesco: string;
  porcentaje: number;
}
export interface DetallePolizaRamo {
  numero: string;
  ramo: Ramo;
  bloques: Record<string, Record<string, string>>;
  garantias: Garantia[];
  beneficiarios: Beneficiario[];
}
export interface EstadoAnterior {
  polizaNumero: string;
  ramo: Ramo;
  producto: string;
  estado: Poliza['estado'];
  fechaEfecto: string;
  fechaBaja: string;
  motivoBaja: string;
}
export interface ReciboDetalle {
  recibo: Recibo;
  producto: string;
  riesgo: string;
  metodoPagoLiteral: string;
  pagador: string;
  estructuraComercial: string;
  cuota: number;
  comisiones: number;
  gestiones: string[];
}
export interface AccionRecibo {
  codigo: string;
  nombre: string;
  tipo: 'EXTERNA' | 'OPERACION' | 'INTERNA';
  url: string | null;
}
export interface DuplicadoRecibo {
  numeroRecibo: string;
  nombreFichero: string;
  tipoMime: string;
  contenidoBase64: string;
}
export interface PrestacionDetalle {
  prestacion: Prestacion;
  importeEstimado: number;
  importePagado: number;
  codigoRamo: string;
  hitos: string[];
  oficinaTramitadora: string;
}

// ---- Pestaña Configuración (solo PGM_ADMINISTRADOR) ----
export interface Secreto {
  nombre: string;
  descripcion: string;
  informado: boolean;
  enmascarado: string | null;
  origen: string | null;
}
export type TipoAutenticacion =
  'NINGUNA' | 'API_KEY' | 'OAUTH_CLIENT_CREDENTIALS' | 'BASIC' | 'CABECERAS' | 'COOKIE';
export interface ServicioConfigurado {
  clave: string;
  nombre: string;
  descripcion: string;
  rutaGateway: string;
  origen: 'API_CANAL' | 'LEGACY';
  autenticacion: TipoAutenticacion;
  urlPorEntorno: Record<string, string>;
  cabeceras: Record<string, string>;
  credenciales: Secreto[];
  habilitado: boolean;
}
export interface Configuracion {
  entorno: string;
  gateway: {
    baseUrl: string;
    tenant: string;
    companyId: string;
    connectTimeoutMs: number;
    readTimeoutMs: number;
    rutas: Record<string, string>;
  };
  servicios: ServicioConfigurado[];
  appian: {
    urlBase: string;
    sitePgm: string;
    siteSgo: string;
    usuarioServicio: string;
    webApis: Record<string, string>;
    apiKey: Secreto;
    habilitado: boolean;
  };
  entraId: {
    habilitado: boolean;
    tenantId: string;
    clientId: string;
    scope: string;
    issuer: string;
    audience: string;
    redirectUris: string[];
    clientSecretBff: Secreto;
  };
  flags: Record<string, boolean>;
  constantes: Record<string, string>;
  usuariosPrueba: {
    usuario: string;
    perfiles: string[];
    nuuma: string | null;
    perfilSgc30: string | null;
    descripcion: string;
  }[];
  ultimaModificacion: string | null;
  modificadoPor: string | null;
}
export interface ResultadoPrueba {
  servicio: string;
  ok: boolean;
  httpStatus: number | null;
  latenciaMs: number;
  url: string;
  mensaje: string;
}
