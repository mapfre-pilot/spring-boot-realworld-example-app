import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { AccionResponse, PopupAppian, PopupLanzadoResponse, PopupResultado } from '../../domain';
import { PopupAppianRepository } from '../../ports';

import { EnvironmentService } from '../../infra/config/environment.service';

@Injectable()
export class PopupAppianHttpRepository implements PopupAppianRepository {
  private readonly http = inject(HttpClient);
  private readonly env = inject(EnvironmentService);

  private get base(): string {
    return String(this.env.config['apiBaseUrl'] ?? '');
  }

  lanzar(clave: string, popup: PopupAppian, idxTomador: number): Observable<PopupLanzadoResponse> {
    return this.http.post<PopupLanzadoResponse>(
      `${this.base}/sesiones/${clave}/popups/${popup}/lanzar/`,
      { idxTomador }
    );
  }

  completar(
    clave: string,
    popup: PopupAppian,
    body: { idxTomador: number; taskId: string; resultado: PopupResultado }
  ): Observable<AccionResponse> {
    return this.http.post<AccionResponse>(
      `${this.base}/sesiones/${clave}/popups/${popup}/completar/`,
      body
    );
  }
}
