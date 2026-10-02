import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import {
  CambioConfiguracion,
  CampoConfiguracion,
  Parametro,
  ResultadoPruebaConfiguracion,
  Traza,
} from '../../domain';
import { EnvironmentService } from '../../infra/config/environment.service';
import { AdminRepository } from '../../ports';

@Injectable()
export class AdminHttpRepository implements AdminRepository {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  parametros(): Observable<Parametro[]> {
    return this.http.get<Parametro[]>(`${this.base}/admin/parametros/`);
  }

  guardarParametro(p: Partial<Parametro>): Observable<Parametro> {
    return this.http.put<Parametro>(`${this.base}/admin/parametros/`, p);
  }

  aperturaCierre(): Observable<{ cerrada: boolean }> {
    return this.http.post<{ cerrada: boolean }>(`${this.base}/admin/apertura-cierre/`, {});
  }

  limpiarCaches(): Observable<Record<string, unknown>> {
    return this.http.post<Record<string, unknown>>(`${this.base}/admin/caches/limpiar/`, {});
  }

  trazas(clave?: string): Observable<Traza[]> {
    let params = new HttpParams();
    if (clave) params = params.set('clave', clave);
    return this.http.get<Traza[]>(`${this.base}/admin/trazas/`, { params });
  }

  configuracion(): Observable<CampoConfiguracion[]> {
    return this.http.get<CampoConfiguracion[]>(`${this.base}/admin/configuracion/`);
  }

  guardarConfiguracion(cambio: CambioConfiguracion): Observable<CampoConfiguracion[]> {
    return this.http.put<CampoConfiguracion[]>(`${this.base}/admin/configuracion/`, cambio);
  }

  probarConfiguracion(grupo: string, nif?: string): Observable<ResultadoPruebaConfiguracion> {
    return this.http.post<ResultadoPruebaConfiguracion>(
      `${this.base}/admin/configuracion/probar/`,
      {
        grupo,
        nif: nif ?? '',
      }
    );
  }
}
