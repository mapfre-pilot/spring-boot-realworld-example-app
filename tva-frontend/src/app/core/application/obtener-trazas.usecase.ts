import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Traza } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ObtenerTrazasUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(clave?: string): Observable<Traza[]> {
    return this.repo.trazas(clave);
  }
}
