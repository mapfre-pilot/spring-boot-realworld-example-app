import { Injectable, inject } from '@angular/core';
import { AuthConfig, OAuthService } from 'angular-oauth2-oidc';
import { environment } from '../../../environments/environment';

/**
 * OIDC authorization code + PKCE contra Microsoft Entra ID (ARCH-FIS-COM-001).
 * En perfil local (`auth.enabled=false`) no hay login: el BFF local resuelve el usuario mock.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly oauth = inject(OAuthService);
  private configured = false;

  get habilitado(): boolean {
    return environment.auth.enabled;
  }

  async initialize(): Promise<void> {
    const { enabled, tenantId, clientId, scopes } = environment.auth;
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
