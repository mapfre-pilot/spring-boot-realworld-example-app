import { Inject, Injectable } from '@angular/core';
import {
  VENCIMIENTOS_REPOSITORY,
  VencimientosRepository,
} from '../ports/vencimientos.repository';
import {
  BusquedaExpedientes,
  CargaFichero,
  Coaseguro,
  EmisionRequest,
  ExpedienteMutation,
  InformeRequest,
  LiquidacionRequest,
  PeticionBdgi,
  VariablesExpediente,
} from '../../domain/models/api.models';

@Injectable({ providedIn: 'root' })
export class VencimientosUseCases {
  constructor(
    @Inject(VENCIMIENTOS_REPOSITORY)
    private readonly repository: VencimientosRepository
  ) {}

  searchExpedientes(criteria: BusquedaExpedientes) {
    return this.repository.searchExpedientes(criteria);
  }

  getExpediente(anio: string, numero: string) {
    return this.repository.getExpediente(anio, numero);
  }

  createExpediente(body: ExpedienteMutation) {
    return this.repository.createExpediente(body);
  }

  updateExpediente(anio: string, numero: string, body: ExpedienteMutation) {
    return this.repository.updateExpediente(anio, numero, body);
  }

  annulExpediente(anio: string, numero: string) {
    return this.repository.annulExpediente(anio, numero);
  }

  getVariables(anio: string, numero: string) {
    return this.repository.getVariables(anio, numero);
  }

  saveVariables(anio: string, numero: string, values: VariablesExpediente) {
    return this.repository.saveVariables(anio, numero, values);
  }

  getCoaseguro(anio: string, numero: string) {
    return this.repository.getCoaseguro(anio, numero);
  }

  saveCoaseguro(anio: string, numero: string, value: Coaseguro) {
    return this.repository.saveCoaseguro(anio, numero, value);
  }

  getFiscalidad(anio: string, numero: string) {
    return this.repository.getFiscalidad(anio, numero);
  }

  getPersona(nif: string) {
    return this.repository.getPersona(nif);
  }

  getCartera(ramo: string, anio: string, numero: string) {
    return this.repository.getCartera(ramo, anio, numero);
  }

  listCarteras(page: number, size: number) {
    return this.repository.listCarteras(page, size);
  }

  calculateLiquidation(body: LiquidacionRequest) {
    return this.repository.calculateLiquidation(body);
  }

  emitFiniquitos(body: EmisionRequest) {
    return this.repository.emitFiniquitos(body);
  }

  printInforme(body: InformeRequest) {
    return this.repository.printInforme(body);
  }

  requestBdgi(body: PeticionBdgi) {
    return this.repository.requestBdgi(body);
  }

  requestReaseguro(anio: string, numero: string) {
    return this.repository.requestReaseguro(anio, numero);
  }

  uploadFile(body: CargaFichero) {
    return this.repository.uploadFile(body);
  }
}
