/**
 * Stub local de `@mapfre-tech/ngx-multienvironment` (paquete corporativo,
 * feed privado de Azure Artifacts).
 *
 * Misma API que usa `main.ts`/`app.config.ts`:
 *  - `initMultiEnvironmentApp()`: lee `assets/environments.json`, elige el
 *    entorno por `window.__TVA_ENV__`, mapa de hostname o 'dev'.
 *  - `provideEnvironment(env, envConfig)`: providers con el env activo.
 *  - `ENVIRONMENT_CONFIG` token + `EnvironmentService`.
 *
 * Swap: instalar el paquete real y restaurar `.npmrc.corporate` → `.npmrc`.
 */
import { Injectable, InjectionToken, inject } from '@angular/core';

export interface EnvironmentConfig {
  apiBaseUrl?: string;
  auth?: {
    mode?: 'local' | 'oidc';
    tokenStorageKey?: string;
    authority?: string;
    clientId?: string;
    scope?: string;
    redirectUrl?: string;
  };
  [key: string]: unknown;
}

export interface MultiEnvironmentInit {
  env: string;
  envConfig: EnvironmentConfig;
}

declare const window: { __TVA_ENV__?: string; location: { hostname: string } };

/** Mapa hostname → entorno. Ajustar a los dominios reales de despliegue. */
const HOST_ENV: Record<string, string> = {
  localhost: 'dev',
  '127.0.0.1': 'dev',
};

export async function initMultiEnvironmentApp(): Promise<MultiEnvironmentInit> {
  const response = await fetch('assets/environments.json');
  const all = (await response.json()) as Record<string, EnvironmentConfig>;
  const env = window.__TVA_ENV__ ?? HOST_ENV[window.location.hostname] ?? 'dev';
  const envConfig = all[env] ?? all['dev'] ?? {};
  return { env, envConfig };
}

export const ENVIRONMENT = new InjectionToken<string>('ENVIRONMENT');
export const ENVIRONMENT_CONFIG = new InjectionToken<EnvironmentConfig>('ENVIRONMENT_CONFIG');

export function provideEnvironment(env: string, envConfig: EnvironmentConfig) {
  return [
    { provide: ENVIRONMENT, useValue: env },
    { provide: ENVIRONMENT_CONFIG, useValue: envConfig },
  ];
}

@Injectable({ providedIn: 'root' })
export class EnvironmentService {
  readonly env = inject(ENVIRONMENT);
  readonly config = inject(ENVIRONMENT_CONFIG);
}
