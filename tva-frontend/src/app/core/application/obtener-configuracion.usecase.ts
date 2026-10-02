import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { CampoConfiguracion } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ObtenerConfiguracionUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(): Observable<CampoConfiguracion[]> {
    return this.repo.configuracion();
  }
}
