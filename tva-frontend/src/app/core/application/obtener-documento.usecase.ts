import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';

@Injectable({ providedIn: 'root' })
export class ObtenerDocumentoUsecase {
  private readonly repo = inject(SESION_REPOSITORY);
  private readonly store = inject(SesionStore);

  execute(tipo: string): Observable<{ tipo: string; documento: Record<string, unknown> }> {
    const clave = this.store.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.repo.obtenerDocumento(clave, tipo);
  }
}
