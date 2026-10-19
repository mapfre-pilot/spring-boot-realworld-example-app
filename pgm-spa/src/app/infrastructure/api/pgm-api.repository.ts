import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { PgmRepository } from '../../application/ports/pgm.repository';
import {
  AuditoriaRequest,
  Cliente,
  ClienteResumen,
  ContextoUsuario,
  CriteriosBusqueda,
  GestionComercial,
  Kpi,
  Lanzadera,
  Lista,
  Oportunidad,
  Poliza,
  Prestacion,
  Presupuesto,
  Ramo,
  Recibo,
  SolicitudSgo,
  TarificacionResultado,
  TarificacionSolicitud,
} from '../../domain/models/api.models';

/** Adaptador HTTP hacia el BFF (/api/v1). Es el único destino de red de la SPA. */
@Injectable({ providedIn: 'root' })
export class PgmApiRepository implements PgmRepository {
  private readonly http = inject(HttpClient);
  private readonly base = `${environment.bffUrl}/api/v1`;

  contexto(): Observable<ContextoUsuario> {
    return this.http.get<ContextoUsuario>(`${this.base}/contexto`);
  }

  buscarClientes(criterios: CriteriosBusqueda): Observable<Lista<ClienteResumen>> {
    let params = new HttpParams();
    Object.entries(criterios)
      .filter(([, v]) => v !== undefined && v !== null && `${v}`.trim() !== '')
      .forEach(([k, v]) => (params = params.set(k === 'texto' ? 'q' : k, `${v}`.trim())));
    return this.http.get<Lista<ClienteResumen>>(`${this.base}/clientes/search`, { params });
  }

  fichaCliente(id: string): Observable<Cliente> {
    return this.http.get<Cliente>(`${this.base}/clientes/${encodeURIComponent(id)}/ficha`);
  }

  productos(clienteId: string, estado?: string): Observable<Lista<Poliza>> {
    const params = estado ? new HttpParams().set('estado', estado) : undefined;
    return this.http.get<Lista<Poliza>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/productos`,
      {
        params,
      },
    );
  }

  recibosCliente(clienteId: string): Observable<Lista<Recibo>> {
    return this.http.get<Lista<Recibo>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/recibos`,
    );
  }

  prestacionesCliente(clienteId: string): Observable<Lista<Prestacion>> {
    return this.http.get<Lista<Prestacion>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/prestaciones`,
    );
  }

  presupuestos(clienteId: string): Observable<Lista<Presupuesto>> {
    return this.http.get<Lista<Presupuesto>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/presupuestos`,
    );
  }

  oportunidades(clienteId: string): Observable<Lista<Oportunidad>> {
    return this.http.get<Lista<Oportunidad>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/oportunidades`,
    );
  }

  gestiones(clienteId: string): Observable<Lista<GestionComercial>> {
    return this.http.get<Lista<GestionComercial>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/gestiones`,
    );
  }

  solicitudesSgo(clienteId: string): Observable<Lista<SolicitudSgo>> {
    return this.http.get<Lista<SolicitudSgo>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/solicitudes-sgo`,
    );
  }

  poliza(numero: string): Observable<Poliza> {
    return this.http.get<Poliza>(`${this.base}/polizas/${encodeURIComponent(numero)}`);
  }

  recibosPoliza(numero: string): Observable<Lista<Recibo>> {
    return this.http.get<Lista<Recibo>>(
      `${this.base}/polizas/${encodeURIComponent(numero)}/recibos`,
    );
  }

  recibo(numero: string): Observable<Recibo> {
    return this.http.get<Recibo>(`${this.base}/recibos/${encodeURIComponent(numero)}`);
  }

  lanzaderas(ramo?: Ramo): Observable<Lista<Lanzadera>> {
    const params = ramo ? new HttpParams().set('ramo', ramo) : undefined;
    return this.http.get<Lista<Lanzadera>>(`${this.base}/lanzaderas`, { params });
  }

  kpis(): Observable<Lista<Kpi>> {
    return this.http.get<Lista<Kpi>>(`${this.base}/cuadro-mando/kpis`);
  }

  tarificarSalud(solicitud: TarificacionSolicitud): Observable<TarificacionResultado> {
    return this.http.post<TarificacionResultado>(`${this.base}/tarificacion/salud`, solicitud);
  }

  guardarBorradorSalud(solicitud: TarificacionSolicitud): Observable<{ id: string }> {
    return this.http.post<{ id: string }>(`${this.base}/tarificacion/salud/borradores`, solicitud);
  }

  borradorSalud(id: string): Observable<TarificacionSolicitud> {
    return this.http.get<TarificacionSolicitud>(
      `${this.base}/tarificacion/salud/borradores/${encodeURIComponent(id)}`,
    );
  }

  llamar(clienteId: string, telefono: string): Observable<{ idLlamada: string }> {
    return this.http.post<{ idLlamada: string }>(`${this.base}/comunicaciones/llamadas`, {
      clienteId,
      telefono,
    });
  }

  auditar(registro: AuditoriaRequest): Observable<void> {
    return this.http.post<void>(`${this.base}/auditoria`, registro);
  }
}
