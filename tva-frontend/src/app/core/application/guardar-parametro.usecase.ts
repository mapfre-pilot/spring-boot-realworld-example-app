import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Parametro } from '../domain';
import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class GuardarParametroUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(parametro: Partial<Parametro>): Observable<Parametro> {
    return this.repo.guardarParametro(parametro);
  }
}
