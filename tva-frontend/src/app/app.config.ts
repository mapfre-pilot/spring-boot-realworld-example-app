import { ApplicationConfig, provideZonelessChangeDetection } from '@angular/core';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import { provideAuth } from 'angular-auth-oidc-client';

import { EnvironmentConfig, provideEnvironment } from '@mapfre-tech/ngx-multienvironment/core';

import { provideTvaCore } from '@tva/core';

import { routes } from './app.routes';

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
              responseType: 'code',
            },
          }),
        ]
      : [];

  return {
    providers: [
      provideZonelessChangeDetection(),
      provideAnimations(),
      provideRouter(routes),
      provideTvaCore(),
      provideEnvironment(env, envConfig),
      ...oidcProviders,
    ],
  };
}
