import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { PgmRepository } from '../../application/ports/pgm.repository';
import {
  ActividadComercial,
  AltaActividad,
  AltaOportunidad,
  AuditoriaRequest,
  BorradorResumen,
  CatalogoComercial,
  Cliente,
  ClienteResumen,
  ContextoUsuario,
  AccionPoliza,
  DocumentoPoliza,
  DetallePolizaRamo,
  EstadoAnterior,
  ReciboDetalle,
  AccionRecibo,
  DuplicadoRecibo,
  PrestacionDetalle,
  MasDatos,
  ContactoActualizado,
  Comunicaciones,
  PeriodoComunicaciones,
  DocumentoCliente,
  FirmaRgpd,
  ResultadoAccion,
  ClienteTotal,
  EmpresaVinculada,
  PlanPagos,
  SimulacionPlanPagos,
  CriteriosBusqueda,
  DocumentoAdjunto,
  FiltroActividad,
  FiltroOportunidades,
  GestionComercial,
  GestionDetalle,
  Kpi,
  Lanzadera,
  Lista,
  Observacion,
  Oportunidad,
  OportunidadDetalle,
  Poliza,
  Prestacion,
  Presupuesto,
  Ramo,
  Recibo,
  ResumenOportunidades,
  SolicitudSgo,
  SolicitudSgoDetalle,
  TarificacionResultado,
  TarificacionSolicitud,
  TipoCatalogoComercial,
} from '../../domain/models/api.models';

function paramsDe(filtro?: Record<string, unknown>): HttpParams {
  let params = new HttpParams();
  Object.entries(filtro ?? {}).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') {
      params = params.set(k, String(v));
    }
  });
  return params;
}

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

  oportunidades(clienteId: string, filtro?: FiltroOportunidades): Observable<Lista<Oportunidad>> {
    return this.http.get<Lista<Oportunidad>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/oportunidades`,
      { params: paramsDe(filtro as Record<string, unknown>) },
    );
  }

  resumenOportunidades(clienteId: string): Observable<ResumenOportunidades> {
    return this.http.get<ResumenOportunidades>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/oportunidades/resumen`,
    );
  }

  oportunidad(id: string): Observable<OportunidadDetalle> {
    return this.http.get<OportunidadDetalle>(
      `${this.base}/oportunidades/${encodeURIComponent(id)}`,
    );
  }

  crearOportunidad(clienteId: string, alta: AltaOportunidad): Observable<Oportunidad> {
    return this.http.post<Oportunidad>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/oportunidades`,
      alta,
      idempotente(),
    );
  }

  observarOportunidad(id: string, texto: string): Observable<Observacion> {
    return this.http.post<Observacion>(
      `${this.base}/oportunidades/${encodeURIComponent(id)}/observaciones`,
      { texto },
      idempotente(),
    );
  }

  eliminarObservacionOportunidad(id: string, obsId: string): Observable<void> {
    return this.http.delete<void>(
      `${this.base}/oportunidades/${encodeURIComponent(id)}/observaciones/${encodeURIComponent(obsId)}`,
    );
  }

  actividadComercial(
    clienteId: string,
    filtro?: FiltroActividad,
  ): Observable<Lista<ActividadComercial>> {
    return this.http.get<Lista<ActividadComercial>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/actividad-comercial`,
      { params: paramsDe(filtro as Record<string, unknown>) },
    );
  }

  crearActividad(clienteId: string, alta: AltaActividad): Observable<ActividadComercial> {
    return this.http.post<ActividadComercial>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/actividad-comercial`,
      alta,
      idempotente(),
    );
  }

  catalogoComercial(tipo: TipoCatalogoComercial): Observable<CatalogoComercial> {
    return this.http.get<CatalogoComercial>(`${this.base}/catalogos-comerciales/${tipo}`);
  }

  gestiones(clienteId: string): Observable<Lista<GestionComercial>> {
    return this.http.get<Lista<GestionComercial>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/gestiones`,
    );
  }

  gestion(id: string): Observable<GestionDetalle> {
    return this.http.get<GestionDetalle>(`${this.base}/gestiones/${encodeURIComponent(id)}`);
  }

  cerrarGestion(id: string, resultado: 'POSITIVA' | 'NEGATIVA'): Observable<GestionComercial> {
    return this.http.post<GestionComercial>(
      `${this.base}/gestiones/${encodeURIComponent(id)}/cierre`,
      { resultado },
      idempotente(),
    );
  }

  reabrirGestion(id: string): Observable<GestionComercial> {
    return this.http.post<GestionComercial>(
      `${this.base}/gestiones/${encodeURIComponent(id)}/reapertura`,
      {},
      idempotente(),
    );
  }

  observarGestion(id: string, texto: string): Observable<Observacion> {
    return this.http.post<Observacion>(
      `${this.base}/gestiones/${encodeURIComponent(id)}/observaciones`,
      { texto },
      idempotente(),
    );
  }

  solicitudesSgo(clienteId: string): Observable<Lista<SolicitudSgo>> {
    return this.http.get<Lista<SolicitudSgo>>(
      `${this.base}/clientes/${encodeURIComponent(clienteId)}/solicitudes-sgo`,
    );
  }

  solicitudSgo(id: string): Observable<SolicitudSgoDetalle> {
    return this.http.get<SolicitudSgoDetalle>(
      `${this.base}/solicitudes-sgo/${encodeURIComponent(id)}`,
    );
  }

  documentosSgo(id: string): Observable<Lista<DocumentoAdjunto>> {
    return this.http.get<Lista<DocumentoAdjunto>>(
      `${this.base}/solicitudes-sgo/${encodeURIComponent(id)}/documentos`,
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
    return this.http.post<TarificacionResultado>(
      `${this.base}/tarificacion/salud`,
      solicitud,
      idempotente(),
    );
  }

  guardarBorradorSalud(solicitud: TarificacionSolicitud): Observable<{ id: string }> {
    return this.http.post<{ id: string }>(
      `${this.base}/tarificacion/salud/borradores`,
      solicitud,
      idempotente(),
    );
  }

  borradorSalud(id: string): Observable<TarificacionSolicitud> {
    return this.http.get<TarificacionSolicitud>(
      `${this.base}/tarificacion/salud/borradores/${encodeURIComponent(id)}`,
    );
  }

  borradoresSalud(): Observable<Lista<BorradorResumen>> {
    return this.http.get<Lista<BorradorResumen>>(`${this.base}/tarificacion/salud/borradores`);
  }

  eliminarBorradorSalud(id: string): Observable<void> {
    return this.http.delete<void>(
      `${this.base}/tarificacion/salud/borradores/${encodeURIComponent(id)}`,
    );
  }

  llamar(clienteId: string, telefono: string): Observable<{ idLlamada: string }> {
    return this.http.post<{ idLlamada: string }>(
      `${this.base}/comunicaciones/llamadas`,
      {
        clienteId,
        telefono,
      },
      idempotente(),
    );
  }

  auditar(registro: AuditoriaRequest): Observable<void> {
    return this.http.post<void>(`${this.base}/auditoria`, registro, idempotente());
  }

  // ---- Menú ACCIONES y palancas de la cabecera ----
  private cliente(id: string): string {
    return `${this.base}/clientes/${encodeURIComponent(id)}`;
  }
  masDatos(clienteId: string): Observable<MasDatos> {
    return this.http.get<MasDatos>(`${this.cliente(clienteId)}/mas-datos`);
  }
  actualizarContacto(clienteId: string, contacto: ContactoActualizado): Observable<MasDatos> {
    return this.http.put<MasDatos>(`${this.cliente(clienteId)}/contacto`, contacto);
  }
  comunicaciones(clienteId: string, periodo: PeriodoComunicaciones): Observable<Comunicaciones> {
    return this.http.get<Comunicaciones>(`${this.cliente(clienteId)}/comunicaciones`, {
      params: new HttpParams().set('periodo', periodo),
    });
  }
  documentosCliente(clienteId: string, tipo?: string): Observable<Lista<DocumentoCliente>> {
    let params = new HttpParams();
    if (tipo) params = params.set('tipo', tipo);
    return this.http.get<Lista<DocumentoCliente>>(`${this.cliente(clienteId)}/documentos`, {
      params,
    });
  }
  solicitarDigitalizacionDni(clienteId: string, canal: string): Observable<ResultadoAccion> {
    return this.http.post<ResultadoAccion>(
      `${this.cliente(clienteId)}/dni/solicitud`,
      { canal },
      idempotente(),
    );
  }
  metodosFirmaRgpd(clienteId: string): Observable<FirmaRgpd> {
    return this.http.get<FirmaRgpd>(`${this.cliente(clienteId)}/rgpd/metodos`);
  }
  firmarRgpd(clienteId: string, metodo: string): Observable<ResultadoAccion> {
    return this.http.post<ResultadoAccion>(
      `${this.cliente(clienteId)}/rgpd/firma`,
      { metodo },
      idempotente(),
    );
  }
  solicitarAltaAci(clienteId: string): Observable<ResultadoAccion> {
    return this.http.post<ResultadoAccion>(`${this.cliente(clienteId)}/aci`, {}, idempotente());
  }
  clienteTotal(clienteId: string): Observable<ClienteTotal> {
    return this.http.get<ClienteTotal>(`${this.cliente(clienteId)}/cliente-total`);
  }
  anadirEmpresaVinculada(clienteId: string, empresa: EmpresaVinculada): Observable<ClienteTotal> {
    return this.http.post<ClienteTotal>(
      `${this.cliente(clienteId)}/cliente-total/empresas`,
      empresa,
      idempotente(),
    );
  }
  planPagos(clienteId: string): Observable<PlanPagos> {
    return this.http.get<PlanPagos>(`${this.cliente(clienteId)}/plan-pagos`);
  }
  simularPlanPagos(
    clienteId: string,
    tipo: 'INDIVIDUAL' | 'FAMILIAR',
  ): Observable<SimulacionPlanPagos> {
    return this.http.post<SimulacionPlanPagos>(`${this.cliente(clienteId)}/plan-pagos/simulacion`, {
      tipo,
    });
  }
  inducir(clienteId: string, canal: string): Observable<ResultadoAccion> {
    return this.http.post<ResultadoAccion>(
      `${this.cliente(clienteId)}/inducciones`,
      { canal },
      idempotente(),
    );
  }

  // ---- Posición del cliente (área B) ----
  fichaPoliza(numero: string): Observable<Poliza> {
    return this.http.get<Poliza>(`${this.base}/polizas/${encodeURIComponent(numero)}/ficha`);
  }
  accionesPoliza(numero: string): Observable<Lista<AccionPoliza>> {
    return this.http.get<Lista<AccionPoliza>>(
      `${this.base}/polizas/${encodeURIComponent(numero)}/acciones`,
    );
  }
  documentosPoliza(numero: string): Observable<Lista<DocumentoPoliza>> {
    return this.http.get<Lista<DocumentoPoliza>>(
      `${this.base}/polizas/${encodeURIComponent(numero)}/documentos`,
    );
  }
  detallePolizaRamo(numero: string): Observable<DetallePolizaRamo> {
    return this.http.get<DetallePolizaRamo>(
      `${this.base}/polizas/${encodeURIComponent(numero)}/detalle-ramo`,
    );
  }
  estadosAnteriores(clienteId: string): Observable<Lista<EstadoAnterior>> {
    return this.http.get<Lista<EstadoAnterior>>(`${this.cliente(clienteId)}/estados-anteriores`);
  }
  accionesRecibo(numero: string): Observable<Lista<AccionRecibo>> {
    return this.http.get<Lista<AccionRecibo>>(
      `${this.base}/recibos/${encodeURIComponent(numero)}/acciones`,
    );
  }
  detalleRecibo(numero: string): Observable<ReciboDetalle> {
    return this.http.get<ReciboDetalle>(
      `${this.base}/recibos/${encodeURIComponent(numero)}/detalle`,
    );
  }
  duplicadoRecibo(numero: string): Observable<DuplicadoRecibo> {
    return this.http.post<DuplicadoRecibo>(
      `${this.base}/recibos/${encodeURIComponent(numero)}/duplicado`,
      {},
    );
  }
  detallePrestacion(numero: string): Observable<PrestacionDetalle> {
    return this.http.get<PrestacionDetalle>(
      `${this.base}/prestaciones/${encodeURIComponent(numero)}`,
    );
  }
}

/** PAT-SYNC-API-001: cada POST lleva una Idempotency-Key nueva (el BFF la usa para no duplicar operaciones en reintentos). */
export function nuevaClaveIdempotencia(): string {
  const c = globalThis.crypto;
  if (c?.randomUUID) return c.randomUUID();
  return `${Date.now().toString(16)}-${Math.random().toString(16).slice(2)}`;
}

function idempotente(): { headers: Record<string, string> } {
  return { headers: { 'Idempotency-Key': nuevaClaveIdempotencia() } };
}
