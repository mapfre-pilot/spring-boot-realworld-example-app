import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { AccionResponse } from '../domain';
import { SESION_REPOSITORY } from '../ports';
import { ACCION_POR_BOTON, SesionStore } from './state/sesion.store';

/** Ejecuta la acción de un botón de la botonera o una acción directa. */
@Injectable({ providedIn: 'root' })
export class EjecutarAccionUsecase {
  private readonly repo = inject(SESION_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(
    accion: string,
    datos: Record<string, unknown> | null = null
  ): Observable<AccionResponse> {
    const clave = this.store.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    const payload = datos ?? this.store.datosPendientes();
    return this.repo.ejecutarAccion(clave, ACCION_POR_BOTON[accion] ?? accion, payload).pipe(
      tap(res => {
        this.store.aplicarRespuesta(res);
        this.store.datosPendientes.set({});
      })
    );
  }
}
