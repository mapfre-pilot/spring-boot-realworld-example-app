/** Servicio de autenticación TVA.
 *
 * - modo `local` (dev): el usuario pega un token HS256 generado en el backend
 *   con `manage.py crear_token_local`. El token se guarda en
 *   `auth.tokenStorageKey` (default `tva_token`).
 * - modo `oidc` (pre/pro): stub — el login real por OIDC queda como TODO
 *   documentado en el README (requiere alta de la app registration EntraID).
 */
import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';

import { EnvironmentService } from '../config/environment.service';

interface JwtClaims {
  sub?: string;
  oid?: string;
  roles?: string[] | string;
  exp?: number;
}

function decodePayload(token: string): JwtClaims {
  try {
    const payload = token.split('.')[1];
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return {};
  }
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly env = inject(EnvironmentService);
  private readonly router = inject(Router);

  private readonly storageKey: string;
  readonly token = signal<string | null>(null);
  readonly usuario = computed(() => decodePayload(this.token() ?? '').sub ?? '');
  readonly roles = computed<string[]>(() => {
    const r = decodePayload(this.token() ?? '').roles;
    return Array.isArray(r) ? r : r ? [r] : [];
  });
  readonly autenticado = computed(() => {
    const t = this.token();
    if (!t) return false;
    const exp = decodePayload(t).exp;
    return exp === undefined || exp * 1000 > Date.now();
  });

  constructor() {
    this.storageKey = this.env.config['auth']?.['tokenStorageKey'] ?? 'tva_token';
    const guardado = localStorage.getItem(this.storageKey);
    if (guardado) this.token.set(guardado);
  }

  get authMode(): 'local' | 'oidc' {
    return this.env.config['auth']?.['mode'] ?? 'local';
  }

  login(token: string): void {
    this.token.set(token.trim());
    localStorage.setItem(this.storageKey, this.token() ?? '');
  }

  /** Login OIDC (pre/pro) — TODO: integrar angular-auth-oidc-client. */
  loginOidc(): void {
    console.warn(
      'Login OIDC pendiente: configurar angular-auth-oidc-client con los datos de environments.json'
    );
  }

  logout(): void {
    this.token.set(null);
    localStorage.removeItem(this.storageKey);
    void this.router.navigate(['/login']);
  }

  hasRole(role: string): boolean {
    return this.roles().includes(role);
  }
}
