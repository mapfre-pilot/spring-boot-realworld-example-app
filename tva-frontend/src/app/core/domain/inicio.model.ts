/** Contrato Appian de la Web API de inicio (§12.4.1). */
import { Aviso, Boton, Canal, EstadoSesion, InvestmentOption, Pantalla } from './sesion.model';
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
