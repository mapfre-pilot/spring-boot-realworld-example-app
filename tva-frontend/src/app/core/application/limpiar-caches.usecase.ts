import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class LimpiarCachesUsecase {
  private readonly repo = inject(ADMIN_REPOSITORY);

  execute(): Observable<Record<string, unknown>> {
    return this.repo.limpiarCaches();
  }
}
