import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { EnvironmentProviders, makeEnvironmentProviders } from '@angular/core';

import {
  AdminHttpRepository,
  CatalogoHttpRepository,
  InicioHttpRepository,
  PopupAppianHttpRepository,
  SesionHttpRepository,
} from './data';
import { authInterceptor } from './infra/auth/auth.interceptor';
import { errorInterceptor } from './infra/http/api-error.interceptor';
import {
  ADMIN_REPOSITORY,
  CATALOGO_REPOSITORY,
  INICIO_REPOSITORY,
  POPUP_APPIAN_REPOSITORY,
  SESION_REPOSITORY,
} from './ports';

export function provideTvaCore(): EnvironmentProviders {
  return makeEnvironmentProviders([
    provideHttpClient(withInterceptors([authInterceptor, errorInterceptor])),
    { provide: SESION_REPOSITORY, useClass: SesionHttpRepository },
    { provide: INICIO_REPOSITORY, useClass: InicioHttpRepository },
    { provide: CATALOGO_REPOSITORY, useClass: CatalogoHttpRepository },
    { provide: POPUP_APPIAN_REPOSITORY, useClass: PopupAppianHttpRepository },
    { provide: ADMIN_REPOSITORY, useClass: AdminHttpRepository },
  ]);
}
