import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { AccionResponse, PopupAppian, PopupResultado } from '../domain';
import { POPUP_APPIAN_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

@Injectable({ providedIn: 'root' })
export class CompletarPopupAppianUsecase {
  private readonly repo = inject(POPUP_APPIAN_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(
    popup: PopupAppian,
    body: { idxTomador: number; taskId: string; resultado: PopupResultado }
  ): Observable<AccionResponse> {
    const clave = this.store.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.repo
      .completar(clave, popup, body)
      .pipe(tap(res => this.store.aplicarRespuesta(res)));
  }
}
