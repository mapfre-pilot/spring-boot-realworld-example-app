import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import {
  CambioConfiguracion,
  CampoConfiguracion,
  Parametro,
  ResultadoPruebaConfiguracion,
  Traza,
} from '../domain';

export interface AdminRepository {
  parametros(): Observable<Parametro[]>;
  guardarParametro(p: Partial<Parametro>): Observable<Parametro>;
  aperturaCierre(): Observable<{ cerrada: boolean }>;
  limpiarCaches(): Observable<Record<string, unknown>>;
  trazas(clave?: string): Observable<Traza[]>;
  configuracion(): Observable<CampoConfiguracion[]>;
  guardarConfiguracion(cambio: CambioConfiguracion): Observable<CampoConfiguracion[]>;
  probarConfiguracion(grupo: string, nif?: string): Observable<ResultadoPruebaConfiguracion>;
}

export const ADMIN_REPOSITORY = new InjectionToken<AdminRepository>('AdminRepository');
