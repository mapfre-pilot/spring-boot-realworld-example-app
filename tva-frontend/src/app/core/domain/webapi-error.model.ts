import { Aviso } from './sesion.model';

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
