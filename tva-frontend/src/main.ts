import { bootstrapApplication } from '@angular/platform-browser';

import { initMultiEnvironmentApp } from '@mapfre-tech/ngx-multienvironment/core';

import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

initMultiEnvironmentApp()
  .then(({ env, envConfig }) => bootstrapApplication(AppComponent, appConfig(env, envConfig)))
  .catch(err => console.error('Error arrancando la aplicación', err));
