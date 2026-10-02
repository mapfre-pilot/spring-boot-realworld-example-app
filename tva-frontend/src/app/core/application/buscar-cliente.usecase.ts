import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { CATALOGO_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class BuscarClienteUsecase {
  private readonly repo = inject(CATALOGO_REPOSITORY);

  execute(documento: string): Observable<Record<string, unknown>> {
    return this.repo.clientes(documento);
  }
}
