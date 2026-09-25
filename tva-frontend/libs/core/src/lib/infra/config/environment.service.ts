/** Acceso a la configuración del entorno activo (tokens del paquete corporativo). */
import { Injectable, inject } from '@angular/core';
import {
  ENVIRONMENT,
  ENVIRONMENT_CONFIG,
  EnvironmentConfig,
} from '@mapfre-tech/ngx-multienvironment/core';

/** Configuración TVA dentro de `EnvironmentConfig` (claves de environments.json). */
export interface TvaEnvironmentConfig extends EnvironmentConfig {
  apiBaseUrl?: string;
  auth?: {
    mode?: 'local' | 'oidc';
    tokenStorageKey?: string;
    authority?: string;
    clientId?: string;
    scope?: string;
    redirectUrl?: string;
  };
  appianEmbed?: {
    baseUrl?: string;
    themeIdentifier?: string;
    signIn?: string;
  };
}

@Injectable({ providedIn: 'root' })
export class EnvironmentService {
  readonly env = inject(ENVIRONMENT);
  readonly config: TvaEnvironmentConfig = inject(ENVIRONMENT_CONFIG) as TvaEnvironmentConfig;
}
