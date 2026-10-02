import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import { InicioRequest, InicioResponse } from '../domain';

export interface InicioRepository {
  iniciarAhorro(req: InicioRequest): Observable<InicioResponse>;
  iniciarRentas(req: InicioRequest): Observable<InicioResponse>;
  salud(): Observable<{ status: string; version: string }>;
}

export const INICIO_REPOSITORY = new InjectionToken<InicioRepository>('InicioRepository');
