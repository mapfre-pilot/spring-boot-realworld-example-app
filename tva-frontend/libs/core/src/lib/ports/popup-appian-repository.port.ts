import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';

import { AccionResponse, PopupAppian, PopupLanzadoResponse, PopupResultado } from '../domain';

export interface PopupAppianRepository {
  lanzar(clave: string, popup: PopupAppian, idxTomador: number): Observable<PopupLanzadoResponse>;
  completar(
    clave: string,
    popup: PopupAppian,
    body: { idxTomador: number; taskId: string; resultado: PopupResultado }
  ): Observable<AccionResponse>;
}

export const POPUP_APPIAN_REPOSITORY = new InjectionToken<PopupAppianRepository>(
  'PopupAppianRepository'
);
