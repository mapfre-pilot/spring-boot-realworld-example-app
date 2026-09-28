import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import { Parametro, Traza } from '../domain';

export interface AdminRepository {
  parametros(): Observable<Parametro[]>;
  guardarParametro(p: Partial<Parametro>): Observable<Parametro>;
  aperturaCierre(): Observable<{ cerrada: boolean }>;
  limpiarCaches(): Observable<Record<string, unknown>>;
  trazas(clave?: string): Observable<Traza[]>;
}

export const ADMIN_REPOSITORY = new InjectionToken<AdminRepository>('AdminRepository');
