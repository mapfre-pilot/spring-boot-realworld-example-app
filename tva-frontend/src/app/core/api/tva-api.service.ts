import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { EnvironmentService } from '@mapfre-tech/ngx-multienvironment/core';

import {
  AccionResponse,
  Aviso,
  InicioRequest,
  InicioResponse,
  Parametro,
  Sesion,
  Traza,
} from '../models/models';

@Injectable({ providedIn: 'root' })
export class TvaApiService {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  salud(): Observable<{ status: string; version: string }> {
    return this.http.get<{ status: string; version: string }>(`${this.base}/salud/`);
  }

  inicioAhorro(req: InicioRequest): Observable<InicioResponse> {
    return this.http.post<InicioResponse>(`${this.base}/inicio/ahorro/`, req);
  }

  inicioRentas(req: InicioRequest): Observable<InicioResponse> {
    return this.http.post<InicioResponse>(`${this.base}/inicio/rentas/`, req);
  }

  getSesion(clave: string): Observable<Sesion> {
    return this.http.get<Sesion>(`${this.base}/sesiones/${clave}/`);
  }

  putEstado(clave: string, estado: Record<string, unknown>, version?: number): Observable<Sesion> {
    return this.http.put<Sesion>(`${this.base}/sesiones/${clave}/estado/`, {
      estado,
      ...(version !== undefined ? { version_esquema: version } : {}),
    });
  }

  accion(
    clave: string,
    accion: string,
    datos: Record<string, unknown> = {}
  ): Observable<AccionResponse> {
    return this.http.post<AccionResponse>(`${this.base}/sesiones/${clave}/acciones/${accion}/`, {
      datos,
    });
  }

  clientes(documento: string): Observable<Record<string, unknown>> {
    return this.http.get<Record<string, unknown>>(`${this.base}/clientes/`, {
      params: new HttpParams().set('documento', documento),
    });
  }

  productos(params?: {
    companyId?: string;
    nuuma?: string;
    distributionChannel?: string;
  }): Observable<{
    products: import('../models/models').Producto[];
  }> {
    let p = new HttpParams();
    for (const [k, v] of Object.entries(params ?? {})) if (v) p = p.set(k, v);
    return this.http.get<{ products: import('../models/models').Producto[] }>(
      `${this.base}/productos/`,
      {
        params: p,
      }
    );
  }

  documento(
    clave: string,
    tipo: string
  ): Observable<{ tipo: string; documento: Record<string, unknown> }> {
    return this.http.get<{ tipo: string; documento: Record<string, unknown> }>(
      `${this.base}/sesiones/${clave}/documentos/${tipo}/`
    );
  }

  // --- admin ---
  adminParametros(): Observable<Parametro[]> {
    return this.http.get<Parametro[]>(`${this.base}/admin/parametros/`);
  }

  adminPutParametro(p: Partial<Parametro>): Observable<Parametro> {
    return this.http.put<Parametro>(`${this.base}/admin/parametros/`, p);
  }

  adminAperturaCierre(): Observable<{ cerrada: boolean }> {
    return this.http.post<{ cerrada: boolean }>(`${this.base}/admin/apertura-cierre/`, {});
  }

  adminLimpiarCaches(): Observable<{ limpiado: boolean }> {
    return this.http.post<{ limpiado: boolean }>(`${this.base}/admin/caches/limpiar/`, {});
  }

  adminTrazas(clave?: string): Observable<Traza[]> {
    const params = clave ? new HttpParams().set('clave', clave) : undefined;
    return this.http.get<Traza[]>(`${this.base}/admin/trazas/`, { params });
  }
}

export type { Aviso };
