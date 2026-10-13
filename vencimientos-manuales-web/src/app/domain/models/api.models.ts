export interface Coaseguradora {
  codigo: string;
  porcentaje: number;
}

export interface Expediente {
  anio: string;
  numero: string;
  ramo?: string;
  anioPoliza?: string;
  numeroPoliza?: string;
  subpoliza?: string;
  certificado?: string;
  nif?: string;
  situacion?: string;
  importeCapital?: number;
  beneficios?: number;
  anticipo?: number;
  interesesPendientes?: number;
  fechaEfecto?: string;
  coaseguradoras?: Coaseguradora[];
}

export type ExpedienteMutation = Omit<Expediente, 'coaseguradoras'> & {
  coaseguradoras?: Coaseguradora[];
};

export interface BusquedaExpedientes {
  anio?: string;
  numero?: string;
  ramo?: string;
  anioPoliza?: string;
  numeroPoliza?: string;
  subpoliza?: string;
  certificado?: string;
  nif?: string;
  page?: number;
  size?: number;
}

export interface PaginaExpedientes {
  content: Expediente[];
  page: number;
  size: number;
  totalElements: number;
}

export interface Coaseguro {
  coaseguradoras: Coaseguradora[];
}

export interface LiquidacionRequest {
  capital: ImporteFiscal;
  prima: ImporteFiscal;
  complementario: ImporteFiscal;
  importeCapital: number;
  beneficios: number;
  anticipo: number;
  interesesPendientes: number;
  coaseguradoras: Coaseguradora[];
}

export interface Liquidacion {
  capital: ImporteCalculado;
  prima: ImporteCalculado;
  complementario: ImporteCalculado;
  liquidoCapital: number;
  importesCoasegurados: number[];
}

export interface ImporteFiscal {
  importe?: number;
  rtoIntegro?: number;
  reduccionPrimas?: number;
  reduccionTransitoria?: number;
  porcentajeRetencion?: number;
  tipoImpuesto?: string;
  codigoPostal?: string;
}

export interface ImporteCalculado {
  importe?: number;
  rtoNeto?: number;
  retencion?: number;
  liquido?: number;
}

export interface PrintJob {
  id?: string;
  estado?: string;
}

export interface Vt06Response {
  solicitudId?: string;
  estado?: string;
  mensaje?: string;
}

export interface Vt07Response {
  cargaId?: string;
  estado?: string;
  mensaje?: string;
}

export interface DatosFiscales {
  nif?: string;
  tipoImpuesto?: string;
  porcentajeRetencion?: number;
  codigoPostal?: string;
}

export interface Cartera {
  ramo: string;
  anioPoliza: string;
  numeroPoliza: string;
  subpoliza?: string;
  modalidad?: string;
  situacion?: string;
}

export interface PaginaCarteras {
  content: Cartera[];
  page: number;
  size: number;
  totalElements: number;
}

export interface Persona {
  nombre: string;
  apellidos: string;
  nif: string;
  domicilio?: string;
  codigoPostal?: string;
  poblacion?: string;
}

export interface VariableExpediente {
  codigo: string;
  valor: string;
}

export interface VariablesExpediente {
  variables: VariableExpediente[];
}

export interface EmisionRequest {
  anio: string;
  expedienteDesde: string;
  expedienteHasta: string;
  fechaEmision?: string;
  tipoEmision?: string;
  lugarEnvio?: string;
}

export interface InformeRequest {
  tipoEmision?: string;
  anioDesde?: string;
  anioHasta?: string;
  expedienteDesde?: string;
  expedienteHasta?: string;
  fechaEmisionDesde?: string;
  fechaEmisionHasta?: string;
  fechaPagoDesde?: string;
  fechaPagoHasta?: string;
}

export interface PeticionBdgi {
  anioEjercicio: number;
  mesEjercicio: number;
  fechaInicial: string;
  fechaFinal: string;
}

export interface CargaFichero {
  tipoEmision: string;
}
