import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import {
  ApplicationConfig,
  DEFAULT_CURRENCY_CODE,
  LOCALE_ID,
  provideAppInitializer,
  provideZonelessChangeDetection,
  inject,
} from '@angular/core';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import {
  AbstractSecurityStorage,
  DefaultLocalStorageService,
  provideAuth,
} from 'angular-auth-oidc-client';

import { EnvironmentConfig, provideEnvironment } from '@mapfre-tech/ngx-multienvironment/core';

import { AuthService, provideTvaCore } from '@tva/core';

import { routes } from './app.routes';

registerLocaleData(localeEs);

export function appConfig(env: string, envConfig: EnvironmentConfig): ApplicationConfig {
  const auth = envConfig['auth'] as Record<string, string> | undefined;
  const oidcProviders =
    auth?.['mode'] === 'oidc'
      ? [
          provideAuth({
            config: {
              authority: auth['authority'],
              clientId: auth['clientId'],
              scope: auth['scope'],
              redirectUrl: auth['redirectUrl'],
              postLogoutRedirectUri: auth['postLogoutRedirectUri'],
              responseType: 'code',
              silentRenew: true,
              useRefreshToken: true,
              renewTimeBeforeTokenExpiresInSeconds: 60,
              autoUserInfo: false,
              ignoreNonceAfterRefresh: true,
              maxIdTokenIatOffsetAllowedInSeconds: 600,
            },
          }),
          // Sesión OIDC compartida entre pestañas (por defecto es sessionStorage).
          { provide: AbstractSecurityStorage, useClass: DefaultLocalStorageService },
          provideAppInitializer(() => inject(AuthService).inicializarOidc()),
        ]
      : [];

  return {
    providers: [
      provideZonelessChangeDetection(),
      { provide: LOCALE_ID, useValue: 'es' },
      { provide: DEFAULT_CURRENCY_CODE, useValue: 'EUR' },
      provideAnimations(),
      provideRouter(routes),
      provideTvaCore(),
      provideEnvironment(env, envConfig),
      ...oidcProviders,
    ],
  };
}
