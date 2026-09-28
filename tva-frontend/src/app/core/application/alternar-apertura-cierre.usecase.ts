import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class AlternarAperturaCierreUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(): Observable<{ cerrada: boolean }> {
    return this.repo.aperturaCierre();
  }
}
