import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { InicioRequest, InicioResponse } from '../domain';
import { INICIO_REPOSITORY } from '../ports';

@Injectable({ providedIn: 'root' })
export class IniciarSesionUsecase {
  private readonly repo = inject(INICIO_REPOSITORY);

  execute(req: InicioRequest): Observable<InicioResponse> {
    return req.indFunctionMode === 'R2C'
      ? this.repo.iniciarRentas(req)
      : this.repo.iniciarAhorro(req);
  }
}
