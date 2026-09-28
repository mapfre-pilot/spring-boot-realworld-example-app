import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { AccionResponse } from '../domain';
import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

/** POST validar-seccion para una sección concreta (§12.4.4). */
@Injectable({ providedIn: 'root' })
export class ValidarSeccionUsecase {
  private readonly repo = inject(SESION_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(
    caja: string,
    seccion: string,
    datos: Record<string, unknown>
  ): Observable<AccionResponse> {
    const clave = this.store.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.repo
      .validarSeccion(clave, caja, seccion, datos)
      .pipe(tap(res => this.store.aplicarRespuesta(res)));
  }
}
