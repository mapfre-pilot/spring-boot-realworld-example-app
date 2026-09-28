import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import { Producto } from '../domain';

export interface CatalogoRepository {
  catalogo(nombre: string): Observable<{ valores: { codigo: string; descripcion: string }[] }>;
  clientes(documento: string): Observable<Record<string, unknown>>;
  productos(params?: {
    companyId?: string;
    nuuma?: string;
    distributionChannel?: string;
  }): Observable<{ products: Producto[] }>;
}

export const CATALOGO_REPOSITORY = new InjectionToken<CatalogoRepository>('CatalogoRepository');
