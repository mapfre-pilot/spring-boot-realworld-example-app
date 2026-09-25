/** Modelos derivados de tva-backend/openapi.yaml y del estado TVA_Sesion (§12.3). */

export type Modalidad = 'VA' | 'VIA' | 'R2C';
export type Canal = 'GV' | 'PFM' | 'OTRO' | string;

export enum Pantalla {
  SISTEMA_CERRADO = 'SISTEMA_CERRADO',
  SIN_PERFIL = 'SIN_PERFIL',
  SOLO_AVISOS = 'SOLO_AVISOS',
  SELECCION_PRODUCTO_AHORRO = 'SELECCION_PRODUCTO_AHORRO',
  SEGUROS_AHORRO = 'SEGUROS_AHORRO',
  MODALIDAD_CAMPANIA = 'MODALIDAD_CAMPANIA',
  CAPTURA_DATOS_SOLICITUD = 'CAPTURA_DATOS_SOLICITUD',
  CAPTURA_TOMADOR1 = 'CAPTURA_TOMADOR1',
  CAPTURA_TOMADOR2 = 'CAPTURA_TOMADOR2',
  RESUMEN_CONTRATACION = 'RESUMEN_CONTRATACION',
  RESULTADO_FIRMA = 'RESULTADO_FIRMA',
  R2C_CAPTURA = 'R2C_CAPTURA',
  R2C_PRECIOS = 'R2C_PRECIOS',
  ADMINISTRACION = 'ADMINISTRACION',
  FIN = 'FIN',
}

/** Aviso Appian {clase, tipo, texto, mostrarEn} (+ codigo/mensaje legacy). */
export interface Aviso {
  clase: number;
  tipo: 'INFO' | 'WARNING' | 'ERROR';
  texto: string;
  mostrarEn: 'CABECERA' | 'SECCION';
  codigo?: string;
  mensaje?: string;
}

/** Botón de la botonera (§12.4.3). */
export interface Boton {
  id: string;
  label: string;
  visible: boolean;
  disabled: boolean;
  confirm?: { header: string; message: string; ok: string; cancel: string };
}

export interface SeccionCaja {
  id: string;
  titulo: string;
  datosValidos: boolean;
  plegada: boolean;
}

export interface Caja {
  id: string;
  titulo: string;
  plegada: boolean;
  secciones: SeccionCaja[];
}

export interface DatosPersonales {
  documentId?: string;
  nombre?: string;
  apellidos?: string;
  fechaNacimiento?: string;
  sexo?: string;
  nacionalidad?: string;
  [k: string]: unknown;
}

export interface Tomador {
  datosPersonales: DatosPersonales;
  domicilioHabitual: Record<string, unknown>;
  mediosContacto: { tipo?: string; prefijo?: string; numero?: string; email?: string }[];
  fatcaCrs?: Record<string, unknown>;
  perfilCliente?: { perfil?: string; testConveniencia?: { estado?: string } };
  datosGestionParticipante?: {
    consentimientoProteccionDatos?: boolean;
    documentoIdDigitalizado?: boolean;
    testConvenienciaVigente?: boolean;
    enviadosDocumentosPrecontractuales?: boolean;
  };
  domiciliaciones?: Record<string, unknown>;
}

export interface InvestmentOption {
  commercialProductCode: string;
  investmentPreferenceCode?: string | null;
  operationTypeCode: 'S' | 'AE' | string;
  policyId?: string | null;
  uniqueContributionAmn?: number | null;
  periodicContributionAmn?: number | null;
  contributionFrequencyCode?: 'M' | 'T' | 'S' | 'A' | string | null;
  insuranceOfferInd?: boolean;
}

/** Estado de sesión estructura TVA_Sesion (§12.3). */
export interface EstadoSesion {
  claveSesion: string;
  modoFuncionamiento: Modalidad;
  codigoProducto?: string | null;
  companyId?: string | null;
  distributionChannel?: string | null;
  perfilUsuario: {
    nuuma?: string;
    oficina?: string;
    productor?: string;
    funcionalidades?: number[];
  };
  tomadores: Tomador[];
  ventaInformada: {
    opcionesInversion: Record<string, unknown>[];
    cestaLibre: unknown[];
    preferencias: Record<string, unknown>;
  };
  datosOperacion: Record<string, unknown>;
  garantias: Record<string, unknown>[];
  comisiones: Record<string, unknown>;
  beneficiarios: Record<string, unknown>;
  cajas: Caja[];
  avisos: Aviso[];
  documentosPrecontractuales: { tipo: string; enviado: boolean }[];
  idPantallaActual: Pantalla | null;
  idPantallaAnterior: Pantalla | null;
  responseProposal: Record<string, unknown>;
  investmentOption: InvestmentOption | null;
  perfilClientesOK: boolean;
  [k: string]: unknown;
}

export interface Sesion {
  clave: string;
  usuario: string;
  modalidad: Modalidad;
  canal: Canal;
  pantalla_actual: Pantalla;
  version_esquema: number;
  estado: EstadoSesion;
  abierta: boolean;
  creado: string;
  actualizado: string;
  botones?: Boton[];
}

/** Contrato Appian de la Web API de inicio (§12.4.1). */
export interface InicioRequest {
  indFunctionMode: 'VA' | 'VIA' | 'R2C';
  proposalId?: string;
  companyId: string;
  distributionChannel: string;
  username: string;
  policyHolders?: Record<string, unknown>[];
  investment?: InvestmentOption[];
  /** legacy */
  documentoCliente?: string;
  canal?: Canal;
  codigoProductor?: string;
  propuesta?: Record<string, unknown>;
}

export interface InicioResponse {
  claveSesion: string;
  pantallaActual: Pantalla;
}

export interface AccionResponse {
  claveSesion: string;
  pantallaActual: Pantalla;
  avisos: Aviso[];
  estado: EstadoSesion;
  botones?: Boton[];
}

export interface WebApiError {
  code: string;
  message: string;
  application: string;
  timestamp: string;
  errors: { code: string; message: string }[];
}

export interface ApiError {
  error: { codigo: string; mensaje: string };
  avisos: Aviso[];
}

export interface Parametro {
  clave: string;
  valor: string;
  tipo: 'str' | 'int' | 'bool' | 'json';
  descripcion: string;
  entorno: string | null;
  actualizado: string;
}

export interface Traza {
  id: number;
  clave_sesion: string;
  tipo_contenido: string;
  clase: 'INFO' | 'ERROR' | 'AVISO';
  mensaje: string;
  datos: Record<string, unknown>;
  creado: string;
}

export interface Producto {
  code?: string;
  commercialProductCode: string;
  commercialProductDesc: string;
  unitLinkedInd?: boolean;
}
