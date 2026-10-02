import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { ResultadoPruebaConfiguracion } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ProbarConfiguracionUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(grupo: string, nif?: string): Observable<ResultadoPruebaConfiguracion> {
    return this.repo.probarConfiguracion(grupo, nif);
  }
}
