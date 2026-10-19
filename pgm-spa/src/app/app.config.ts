import {
  ApplicationConfig,
  importProvidersFrom,
  inject,
  provideAppInitializer,
  provideZoneChangeDetection,
} from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import { LOCALE_ID } from '@angular/core';
import { OAuthModule } from 'angular-oauth2-oidc';
import { appRoutes } from './app.routes';
import { PGM_REPOSITORY } from './application/ports/pgm.repository';
import { PgmApiRepository } from './infrastructure/api/pgm-api.repository';
import { problemDetailsInterceptor } from './infrastructure/api/problem-details.interceptor';
import { authInterceptor } from './infrastructure/auth/auth.interceptor';
import { AuthService } from './infrastructure/auth/auth.service';

registerLocaleData(localeEs);

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(appRoutes, withComponentInputBinding()),
    provideHttpClient(withInterceptors([authInterceptor, problemDetailsInterceptor])),
    importProvidersFrom(OAuthModule.forRoot()),
    { provide: LOCALE_ID, useValue: 'es-ES' },
    { provide: PGM_REPOSITORY, useClass: PgmApiRepository },
    provideAppInitializer(() => inject(AuthService).initialize()),
  ],
};
