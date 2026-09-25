import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { PopupAppian, PopupLanzadoResponse } from '../domain';
import { POPUP_APPIAN_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

@Injectable({ providedIn: 'root' })
export class LanzarPopupAppianUsecase {
  private readonly repo = inject(POPUP_APPIAN_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(popup: PopupAppian, idxTomador: number): Observable<PopupLanzadoResponse> {
    const clave = this.store.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.repo.lanzar(clave, popup, idxTomador);
  }
}
