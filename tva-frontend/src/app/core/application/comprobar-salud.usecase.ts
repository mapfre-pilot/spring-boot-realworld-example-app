import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { INICIO_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ComprobarSaludUsecase {
  private readonly repo = inject(INICIO_REPOSITORY);

  execute(): Observable<{ status: string; version: string }> {
    return this.repo.salud();
  }
}
