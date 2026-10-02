import { Injectable, inject } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { Sesion } from '../domain';
import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

@Injectable({ providedIn: 'root' })
export class CargarSesionUsecase {
  private readonly repo = inject(SESION_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(clave: string): Observable<Sesion> {
    this.store.cargando.set(true);
    return this.repo.obtener(clave).pipe(
      tap({
        next: s => {
          this.store.aplicarRespuesta(s);
          this.store.cargando.set(false);
        },
        error: () => this.store.cargando.set(false),
      })
    );
  }
}
