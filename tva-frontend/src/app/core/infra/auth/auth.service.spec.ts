import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

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
