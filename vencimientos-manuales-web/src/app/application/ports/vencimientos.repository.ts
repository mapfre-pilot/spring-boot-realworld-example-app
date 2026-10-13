import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';
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

export interface VencimientosRepository {
  searchExpedientes(
    criteria: BusquedaExpedientes
  ): Observable<PaginaExpedientes>;
  getExpediente(anio: string, numero: string): Observable<Expediente>;
  createExpediente(body: ExpedienteMutation): Observable<Expediente>;
  updateExpediente(
    anio: string,
    numero: string,
    body: ExpedienteMutation
  ): Observable<Expediente>;
  annulExpediente(anio: string, numero: string): Observable<void>;
  getVariables(anio: string, numero: string): Observable<VariablesExpediente>;
  saveVariables(
    anio: string,
    numero: string,
    values: VariablesExpediente
  ): Observable<VariablesExpediente>;
  getCoaseguro(anio: string, numero: string): Observable<Coaseguro>;
  saveCoaseguro(
    anio: string,
    numero: string,
    value: Coaseguro
  ): Observable<Coaseguro>;
  getFiscalidad(anio: string, numero: string): Observable<DatosFiscales>;
  getPersona(nif: string): Observable<Persona>;
  getCartera(ramo: string, anio: string, numero: string): Observable<Cartera>;
  listCarteras(page: number, size: number): Observable<PaginaCarteras>;
  calculateLiquidation(body: LiquidacionRequest): Observable<Liquidacion>;
  emitFiniquitos(body: EmisionRequest): Observable<PrintJob>;
  printInforme(body: InformeRequest): Observable<PrintJob>;
  requestBdgi(body: PeticionBdgi): Observable<Vt06Response>;
  requestReaseguro(anio: string, numero: string): Observable<void>;
  uploadFile(body: CargaFichero): Observable<Vt07Response>;
}

export const VENCIMIENTOS_REPOSITORY =
  new InjectionToken<VencimientosRepository>('VENCIMIENTOS_REPOSITORY');
