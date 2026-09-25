import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { appRoutes } from './app.routes';
import { EnvironmentConfig, provideEnvironment } from '@mapfre-tech/ngx-multienvironment/core';

export const getAppConfig: (
  config: { env: string; envConfig: EnvironmentConfig; }
) => ApplicationConfig = config => ({
  providers: [
    provideRouter(appRoutes),
    provideEnvironment(config.env, config.envConfig),
  ],
});
