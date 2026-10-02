import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { CambioConfiguracion, CampoConfiguracion } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class GuardarConfiguracionUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(cambio: CambioConfiguracion): Observable<CampoConfiguracion[]> {
    return this.repo.guardarConfiguracion(cambio);
  }
}
