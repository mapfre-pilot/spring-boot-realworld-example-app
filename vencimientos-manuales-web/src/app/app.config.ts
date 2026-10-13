import {
  ApplicationConfig,
  importProvidersFrom,
  inject,
  provideAppInitializer,
  provideZoneChangeDetection,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { OAuthModule } from 'angular-oauth2-oidc';
import { appRoutes } from './app.routes';
import { authInterceptor } from './infrastructure/auth/auth.interceptor';
import { problemDetailsInterceptor } from './infrastructure/api/problem-details.interceptor';
import { VENCIMIENTOS_REPOSITORY } from './application/ports/vencimientos.repository';
import { VencimientosApiRepository } from './infrastructure/api/vencimientos-api.repository';
import { AuthService } from './infrastructure/auth/auth.service';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(appRoutes),
    provideHttpClient(
      withInterceptors([authInterceptor, problemDetailsInterceptor])
    ),
    importProvidersFrom(OAuthModule.forRoot()),
    { provide: VENCIMIENTOS_REPOSITORY, useClass: VencimientosApiRepository },
    provideAppInitializer(() => inject(AuthService).initialize()),
  ],
};
