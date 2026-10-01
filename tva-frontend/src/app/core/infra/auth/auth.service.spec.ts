import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { of } from 'rxjs';

import { AuthService } from './auth.service';

const TOK = `x.${btoa(JSON.stringify({ sub: 'operador1', roles: ['TVA_USUARIO'], exp: 9999999999 }))}.y`;

describe('AuthService', () => {
  let auth: AuthService;
  const router = { navigate: jest.fn() };
  beforeEach(() => {
    localStorage.clear();
    TestBed.configureTestingModule({
      providers: [
        { provide: ENVIRONMENT, useValue: 'dev' },
        { provide: ENVIRONMENT_CONFIG, useValue: {} },
        { provide: Router, useValue: router },
      ],
    });
    auth = TestBed.inject(AuthService);
  });

  it('arranca sin token y decodifica claims tras login', () => {
    expect(auth.token()).toBeNull();
    expect(auth.autenticado()).toBe(false);
    auth.login(TOK);
    expect(auth.usuario()).toBe('operador1');
    expect(auth.roles()).toEqual(['TVA_USUARIO']);
    expect(auth.autenticado()).toBe(true);
    expect(localStorage.getItem('tva_token')).toBe(TOK);
  });

  it('restaura el token guardado en localStorage', () => {
    localStorage.setItem('tva_token', TOK);
    // nueva instancia para forzar lectura del storage
    TestBed.resetTestingModule();
    TestBed.configureTestingModule({
      providers: [
        { provide: ENVIRONMENT, useValue: 'dev' },
        { provide: ENVIRONMENT_CONFIG, useValue: {} },
        { provide: Router, useValue: router },
      ],
    });
    const fresh = TestBed.inject(AuthService);
    expect(fresh.token()).toBe(TOK);
  });

  it('logout borra token y navega a login', () => {
    auth.login(TOK);
    auth.logout();
    expect(auth.token()).toBeNull();
    expect(localStorage.getItem('tva_token')).toBeNull();
    expect(router.navigate).toHaveBeenCalledWith(['/login']);
  });

  it('hasRole y authMode', () => {
    auth.login(TOK);
    expect(auth.hasRole('TVA_USUARIO')).toBe(true);
    expect(auth.hasRole('OTRO')).toBe(false);
    expect(auth.authMode).toBe('local');
  });
});

const b64 = (o: object) => btoa(JSON.stringify(o)).replace(/=/g, '');
const tokOidc = (claims: object) =>
  `${b64({ alg: 'RS256' })}.${b64({ exp: 9999999999, ...claims })}.sig`;

describe('AuthService (modo oidc)', () => {
  function setup(configAuth: Record<string, unknown>) {
    localStorage.clear();
    const oidc = {
      checkAuth: jest
        .fn()
        .mockReturnValue(
          of({
            isAuthenticated: true,
            accessToken: tokOidc({ preferred_username: 'op@mapfre.net' }),
          })
        ),
      isAuthenticated$: of({ isAuthenticated: true }),
      getAccessToken: jest
        .fn()
        .mockReturnValue(of(tokOidc({ preferred_username: 'op@mapfre.net' }))),
      authorize: jest.fn(),
      logoffAndRevokeTokens: jest.fn().mockReturnValue(of({})),
    };
    TestBed.resetTestingModule();
    TestBed.configureTestingModule({
      providers: [
        { provide: ENVIRONMENT, useValue: 'local-sso' },
        { provide: ENVIRONMENT_CONFIG, useValue: { auth: { mode: 'oidc', ...configAuth } } },
        { provide: Router, useValue: { navigate: jest.fn() } },
        { provide: OidcSecurityService, useValue: oidc },
      ],
    });
    return { auth: TestBed.inject(AuthService), oidc };
  }

  it('checkAuth autenticado fija el token y el usuario (preferred_username)', () => {
    const { auth } = setup({});
    expect(auth.authMode).toBe('oidc');
    auth.inicializarOidc();
    expect(auth.token()).not.toBeNull();
    expect(auth.usuario()).toBe('op@mapfre.net');
  });

  it('aplica defaultRoles si el token no trae roles y los del claim tienen prioridad', () => {
    const { auth } = setup({ defaultRoles: ['TVA_USUARIO', 'TVA_ADMIN_PORTAL'] });
    auth.inicializarOidc();
    expect(auth.roles()).toEqual(['TVA_USUARIO', 'TVA_ADMIN_PORTAL']);
    auth.token.set(tokOidc({ roles: ['TVA_DEBUG'] }));
    expect(auth.roles()).toEqual(['TVA_DEBUG']);
  });

  it('no guarda el access token OIDC en localStorage y logout llama a logoff', () => {
    const { auth, oidc } = setup({ tokenStorageKey: 'tva_token' });
    auth.inicializarOidc();
    expect(localStorage.getItem('tva_token')).toBeNull();
    auth.logout();
    expect(oidc.logoffAndRevokeTokens).toHaveBeenCalled();
    expect(auth.token()).toBeNull();
  });

  it('inicializarOidc no hace nada en modo local', () => {
    const { oidc } = setup({ mode: 'local' });
    const auth = TestBed.inject(AuthService);
    auth.inicializarOidc();
    expect(oidc.checkAuth).not.toHaveBeenCalled();
  });
});
