import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { AccionResponse, Sesion } from '../../domain';
import { SesionRepository } from '../../ports';

import { EnvironmentService } from '../../infra/config/environment.service';

@Injectable()
export class SesionHttpRepository implements SesionRepository {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  obtener(clave: string): Observable<Sesion> {
    return this.http.get<Sesion>(`${this.base}/sesiones/${clave}/`);
  }

  guardarEstado(
    clave: string,
    estado: Record<string, unknown>,
    version?: number
  ): Observable<Sesion> {
    return this.http.put<Sesion>(`${this.base}/sesiones/${clave}/estado/`, {
      estado,
      ...(version !== undefined ? { version_esquema: version } : {}),
    });
  }

  ejecutarAccion(
    clave: string,
    accion: string,
    datos: Record<string, unknown> = {}
  ): Observable<AccionResponse> {
    return this.http.post<AccionResponse>(`${this.base}/sesiones/${clave}/acciones/${accion}/`, {
      datos,
    });
  }

  validarSeccion(
    clave: string,
    caja: string,
    seccion: string,
    datos: Record<string, unknown>
  ): Observable<AccionResponse> {
    return this.ejecutarAccion(clave, 'validar-seccion', { caja, seccion, datos });
  }

  obtenerDocumento(
    clave: string,
    tipo: string
  ): Observable<{ tipo: string; documento: Record<string, unknown> }> {
    return this.http.get<{ tipo: string; documento: Record<string, unknown> }>(
      `${this.base}/sesiones/${clave}/documentos/${tipo}/`
    );
  }
}
