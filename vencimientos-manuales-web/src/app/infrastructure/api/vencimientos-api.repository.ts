import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { VencimientosRepository } from '../../application/ports/vencimientos.repository';
import {
  BusquedaExpedientes,
  CargaFichero,
  Cartera,
  Coaseguro,
  DatosFiscales,
  EmisionRequest,
  Expediente,
  ExpedienteMutation,
  InformeRequest,
  Liquidacion,
  LiquidacionRequest,
  PaginaCarteras,
  PaginaExpedientes,
  PeticionBdgi,
  Persona,
  PrintJob,
  VariablesExpediente,
  Vt06Response,
  Vt07Response,
} from '../../domain/models/api.models';

@Injectable({ providedIn: 'root' })
export class VencimientosApiRepository implements VencimientosRepository {
  private readonly baseUrl = `${environment.bffUrl}/api/v1`;

  constructor(private readonly http: HttpClient) {}

  searchExpedientes(
    criteria: BusquedaExpedientes
  ): Observable<PaginaExpedientes> {
    let params = new HttpParams();
    Object.entries(criteria).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        params = params.set(key, String(value));
      }
    });
    return this.http.get<PaginaExpedientes>(`${this.baseUrl}/expedientes`, {
      params,
    });
  }

  getExpediente(anio: string, numero: string): Observable<Expediente> {
    return this.http.get<Expediente>(
      `${this.baseUrl}/expedientes/${anio}/${numero}`
    );
  }

  createExpediente(body: ExpedienteMutation): Observable<Expediente> {
    return this.http.post<Expediente>(`${this.baseUrl}/expedientes`, body, {
      headers: { 'Idempotency-Key': crypto.randomUUID() },
    });
  }

  updateExpediente(
    anio: string,
    numero: string,
    body: ExpedienteMutation
  ): Observable<Expediente> {
    return this.http.put<Expediente>(
      `${this.baseUrl}/expedientes/${anio}/${numero}`,
      body
    );
  }

  annulExpediente(anio: string, numero: string): Observable<void> {
    return this.http.post<void>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/anulacion`,
      {},
      { headers: { 'Idempotency-Key': crypto.randomUUID() } }
    );
  }

  getVariables(anio: string, numero: string): Observable<VariablesExpediente> {
    return this.http.get<VariablesExpediente>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/variables`
    );
  }

  saveVariables(
    anio: string,
    numero: string,
    values: VariablesExpediente
  ): Observable<VariablesExpediente> {
    return this.http.put<VariablesExpediente>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/variables`,
      values
    );
  }

  getCoaseguro(anio: string, numero: string): Observable<Coaseguro> {
    return this.http.get<Coaseguro>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/coaseguro`
    );
  }

  saveCoaseguro(
    anio: string,
    numero: string,
    value: Coaseguro
  ): Observable<Coaseguro> {
    return this.http.put<Coaseguro>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/coaseguro`,
      value
    );
  }

  getFiscalidad(anio: string, numero: string): Observable<DatosFiscales> {
    return this.http.get<DatosFiscales>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/fiscalidad`
    );
  }

  getPersona(nif: string): Observable<Persona> {
    return this.http.get<Persona>(`${this.baseUrl}/personas`, {
      params: { nif },
    });
  }

  getCartera(ramo: string, anio: string, numero: string): Observable<Cartera> {
    return this.http.get<Cartera>(
      `${this.baseUrl}/polizas/${ramo}/${anio}/${numero}/cartera`
    );
  }

  listCarteras(page: number, size: number): Observable<PaginaCarteras> {
    return this.http.get<PaginaCarteras>(`${this.baseUrl}/carteras/listado`, {
      params: { page, size },
    });
  }

  calculateLiquidation(body: LiquidacionRequest): Observable<Liquidacion> {
    return this.http.post<Liquidacion>(
      `${this.baseUrl}/calculos/liquidacion`,
      body
    );
  }

  emitFiniquitos(body: EmisionRequest): Observable<PrintJob> {
    return this.http.post<PrintJob>(
      `${this.baseUrl}/finiquitos/emisiones`,
      body,
      { headers: { 'Idempotency-Key': crypto.randomUUID() } }
    );
  }

  printInforme(body: InformeRequest): Observable<PrintJob> {
    return this.http.post<PrintJob>(`${this.baseUrl}/informes`, body, {
      headers: { 'Idempotency-Key': crypto.randomUUID() },
    });
  }

  requestBdgi(body: PeticionBdgi): Observable<Vt06Response> {
    return this.http.post<Vt06Response>(
      `${this.baseUrl}/peticiones-bdgi`,
      body,
      { headers: { 'Idempotency-Key': crypto.randomUUID() } }
    );
  }

  requestReaseguro(anio: string, numero: string): Observable<void> {
    return this.http.post<void>(
      `${this.baseUrl}/expedientes/${anio}/${numero}/reaseguro`,
      {},
      { headers: { 'Idempotency-Key': crypto.randomUUID() } }
    );
  }

  uploadFile(body: CargaFichero): Observable<Vt07Response> {
    return this.http.post<Vt07Response>(
      `${this.baseUrl}/cargas-fichero`,
      body,
      { headers: { 'Idempotency-Key': crypto.randomUUID() } }
    );
  }
}
