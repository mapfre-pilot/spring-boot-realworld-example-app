import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { CATALOGO_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ObtenerCatalogoUsecase {
  private readonly repo = inject(CATALOGO_REPOSITORY);

  execute(nombre: string): Observable<{ valores: { codigo: string; descripcion: string }[] }> {
    return this.repo.catalogo(nombre);
  }
}
