import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import { AccionResponse, Sesion } from '../domain';

export interface SesionRepository {
  obtener(clave: string): Observable<Sesion>;
  guardarEstado(
    clave: string,
    estado: Record<string, unknown>,
    version?: number
  ): Observable<Sesion>;
  ejecutarAccion(
    clave: string,
    accion: string,
    datos: Record<string, unknown>
  ): Observable<AccionResponse>;
  validarSeccion(
    clave: string,
    caja: string,
    seccion: string,
    datos: Record<string, unknown>
  ): Observable<AccionResponse>;
  obtenerDocumento(
    clave: string,
    tipo: string
  ): Observable<{ tipo: string; documento: Record<string, unknown> }>;
}

export const SESION_REPOSITORY = new InjectionToken<SesionRepository>('SesionRepository');
