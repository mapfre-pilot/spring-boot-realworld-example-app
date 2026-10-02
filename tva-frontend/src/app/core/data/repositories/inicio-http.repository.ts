import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { InicioRequest, InicioResponse } from '../../domain';
import { InicioRepository } from '../../ports';

import { EnvironmentService } from '../../infra/config/environment.service';

@Injectable()
export class InicioHttpRepository implements InicioRepository {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  iniciarAhorro(req: InicioRequest): Observable<InicioResponse> {
    return this.http.post<InicioResponse>(`${this.base}/inicio/ahorro/`, req);
  }

  iniciarRentas(req: InicioRequest): Observable<InicioResponse> {
    return this.http.post<InicioResponse>(`${this.base}/inicio/rentas/`, req);
  }

  salud(): Observable<{ status: string; version: string }> {
    return this.http.get<{ status: string; version: string }>(`${this.base}/salud/`);
  }
}
