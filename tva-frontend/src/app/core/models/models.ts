/** Modelos derivados de tva-backend/openapi.yaml */

export type Modalidad = 'VA' | 'VIA' | 'R2C';
export type Canal = 'GV' | 'PFM' | 'OTRO';

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

export interface Aviso {
  clase: number;
  codigo: string;
  mensaje: string;
}

export interface Sesion {
  clave: string;
  usuario: string;
  modalidad: Modalidad;
  canal: Canal;
  pantalla_actual: Pantalla;
  version_esquema: number;
  estado: Record<string, unknown>;
  abierta: boolean;
  creado: string;
  actualizado: string;
}

export interface InicioRequest {
  documentoCliente: string;
  canal: Canal;
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
  estado: Record<string, unknown>;
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
  productCode: string;
  productDesc: string;
  modalidades?: string[];
}
