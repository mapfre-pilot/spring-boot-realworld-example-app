import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Parametro } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ObtenerParametrosUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(): Observable<Parametro[]> {
    return this.repo.parametros();
  }
}
