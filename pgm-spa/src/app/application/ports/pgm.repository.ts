import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';
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

/** Puerto de salida de la SPA: toda la información llega del BFF, nunca de API Canal ni de plataformas directamente. */
export interface PgmRepository {
  contexto(): Observable<ContextoUsuario>;
  buscarClientes(criterios: CriteriosBusqueda): Observable<Lista<ClienteResumen>>;
  fichaCliente(id: string): Observable<Cliente>;
  productos(clienteId: string, estado?: string): Observable<Lista<Poliza>>;
  recibosCliente(clienteId: string): Observable<Lista<Recibo>>;
  prestacionesCliente(clienteId: string): Observable<Lista<Prestacion>>;
  presupuestos(clienteId: string): Observable<Lista<Presupuesto>>;
  oportunidades(clienteId: string): Observable<Lista<Oportunidad>>;
  gestiones(clienteId: string): Observable<Lista<GestionComercial>>;
  solicitudesSgo(clienteId: string): Observable<Lista<SolicitudSgo>>;
  poliza(numero: string): Observable<Poliza>;
  recibosPoliza(numero: string): Observable<Lista<Recibo>>;
  recibo(numero: string): Observable<Recibo>;
  lanzaderas(ramo?: Ramo): Observable<Lista<Lanzadera>>;
  kpis(): Observable<Lista<Kpi>>;
  tarificarSalud(solicitud: TarificacionSolicitud): Observable<TarificacionResultado>;
  guardarBorradorSalud(solicitud: TarificacionSolicitud): Observable<{ id: string }>;
  borradorSalud(id: string): Observable<TarificacionSolicitud>;
  llamar(clienteId: string, telefono: string): Observable<{ idLlamada: string }>;
  auditar(registro: AuditoriaRequest): Observable<void>;
}

export const PGM_REPOSITORY = new InjectionToken<PgmRepository>('PGM_REPOSITORY');
