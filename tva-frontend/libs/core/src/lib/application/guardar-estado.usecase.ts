import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { EstadoSesion, Sesion } from '../domain';
import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

@Injectable({ providedIn: 'root' })
export class GuardarEstadoUsecase {
  private readonly repo = inject(SESION_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(patch: Record<string, unknown>): Observable<Sesion> {
    const s = this.store.sesion();
    if (!s) throw new Error('Sin sesión cargada');
    const nuevo = { ...s.estado, ...patch } as EstadoSesion;
    return this.repo
      .guardarEstado(s.clave, nuevo as unknown as Record<string, unknown>)
      .pipe(tap(res => this.store.sesion.set(res)));
  }
}
