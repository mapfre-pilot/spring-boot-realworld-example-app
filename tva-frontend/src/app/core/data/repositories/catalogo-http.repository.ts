import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Producto } from '../../domain';
import { EnvironmentService } from '../../infra/config/environment.service';
import { CatalogoRepository } from '../../ports';

@Injectable()
export class CatalogoHttpRepository implements CatalogoRepository {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  catalogo(nombre: string): Observable<{ valores: { codigo: string; descripcion: string }[] }> {
    return this.http.get<{ valores: { codigo: string; descripcion: string }[] }>(
      `${this.base}/catalogos/${nombre}/`
    );
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
  }): Observable<{ products: Producto[] }> {
    let p = new HttpParams();
    for (const [k, v] of Object.entries(params ?? {})) if (v) p = p.set(k, v);
    return this.http.get<{ products: Producto[] }>(`${this.base}/productos/`, { params: p });
  }
}
