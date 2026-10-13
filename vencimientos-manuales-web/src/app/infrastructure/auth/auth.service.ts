import { Injectable } from '@angular/core';
import { AuthConfig, OAuthService } from 'angular-oauth2-oidc';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private configured = false;

  constructor(private readonly oauth: OAuthService) {}

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
  }

  login(): void {
    if (this.configured) this.oauth.initCodeFlow();
  }

  logout(): void {
    if (this.configured) this.oauth.logOut();
  }
}
