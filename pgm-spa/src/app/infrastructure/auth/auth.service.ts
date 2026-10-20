import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AuthConfig, OAuthService } from 'angular-oauth2-oidc';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ConfiguracionPublica } from '../../domain/models/api.models';

/**
 * OIDC authorization code + PKCE contra Microsoft Entra ID (ARCH-FIS-COM-001).
 * Los parámetros (habilitado, tenant, clientId, scope) se leen del BFF (`/configuracion/publica`, pestaña Configuración);
 * si el BFF no responde se usa `environment.auth`. Con el login desactivado el BFF resuelve el usuario por cabeceras (local/pruebas).
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly oauth = inject(OAuthService);
  private readonly http = inject(HttpClient);
  private configured = false;
  readonly activo = signal(environment.auth.enabled);
  readonly publica = signal<ConfiguracionPublica | null>(null);

  get habilitado(): boolean {
    return this.activo();
  }

  async initialize(): Promise<void> {
    let enabled = environment.auth.enabled;
    let tenantId = environment.auth.tenantId;
    let clientId = environment.auth.clientId;
    let scopes = environment.auth.scopes;
    try {
      const pub = await firstValueFrom(
        this.http.get<ConfiguracionPublica>(`${environment.bffUrl}/api/v1/configuracion/publica`),
      );
      this.publica.set(pub);
      enabled = pub.entraIdHabilitado;
      if (pub.tenantId && pub.clientId) {
        tenantId = pub.tenantId;
        clientId = pub.clientId;
        scopes = ['openid', 'profile', pub.scope ?? `api://${pub.clientId}/pgm.acceso`];
      }
    } catch {
      /* BFF no disponible: se mantiene environment.auth */
    }
    this.activo.set(enabled);
    if (!enabled || !tenantId || !clientId) return;
    const config: AuthConfig = {
      issuer: `https://login.microsoftonline.com/${tenantId}/v2.0`,
      clientId,
      responseType: 'code',
      redirectUri: window.location.origin,
      scope: scopes.join(' '),
      strictDiscoveryDocumentValidation: false,
    };
    this.oauth.configure(config);
    await this.oauth.loadDiscoveryDocumentAndTryLogin();
    this.configured = true;
    if (!this.oauth.hasValidAccessToken()) this.oauth.initCodeFlow();
  }

  accessToken(): string | null {
    return this.configured && this.oauth.hasValidAccessToken() ? this.oauth.getAccessToken() : null;
  }

  logout(): void {
    if (this.configured) this.oauth.logOut();
  }
}
