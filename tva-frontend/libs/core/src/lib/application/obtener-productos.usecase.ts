import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Producto } from '../domain';
import { CATALOGO_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class ObtenerProductosUsecase {
  private readonly repo = inject(CATALOGO_REPOSITORY);

  execute(params?: {
    companyId?: string;
    nuuma?: string;
    distributionChannel?: string;
  }): Observable<{ products: Producto[] }> {
    return this.repo.productos(params);
  }
}
