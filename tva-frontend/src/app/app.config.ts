import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { ApplicationConfig, provideZonelessChangeDetection } from '@angular/core';
import { provideAnimations } from '@angular/platform-browser/animations';
import { provideRouter } from '@angular/router';
import { provideAuth } from 'angular-auth-oidc-client';

import { EnvironmentConfig, provideEnvironment } from '@mapfre-tech/ngx-multienvironment/core';

import { errorInterceptor } from './core/api/api-error.interceptor';
import { authInterceptor } from './core/auth/auth.interceptor';
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
      provideHttpClient(withInterceptors([authInterceptor, errorInterceptor])),
      provideEnvironment(env, envConfig),
      ...oidcProviders,
    ],
  };
}
