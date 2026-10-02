import { Spectator, createComponentFactory } from '@ngneat/spectator/jest';
import { Router } from '@angular/router';

import { AuthService } from '@tva/core';
import { BienvenidaPage } from './bienvenida.page';

describe('BienvenidaPage (oidc)', () => {
  const auth = { authMode: 'oidc', autenticado: () => false, loginOidc: jest.fn() };
  const router = { navigate: jest.fn() };
  const create = createComponentFactory({
    component: BienvenidaPage,
    providers: [
      { provide: AuthService, useValue: auth },
      { provide: Router, useValue: router },
    ],
  });

  it('muestra el botón SSO y lanza loginOidc al pulsarlo', () => {
    const s: Spectator<BienvenidaPage> = create();
    expect(s.query('.hero-titulo')?.textContent).toContain('Bienvenido a TVA');
    expect(s.query('.acceso-boton')?.textContent).toContain('Iniciar sesión con SSO');
    s.click('.acceso-boton');
    expect(auth.loginOidc).toHaveBeenCalled();
    expect(router.navigate).not.toHaveBeenCalled();
  });
});

describe('BienvenidaPage (local)', () => {
  const router = { navigate: jest.fn() };
  const create = createComponentFactory({
    component: BienvenidaPage,
    providers: [
      {
        provide: AuthService,
        useValue: { authMode: 'local', autenticado: () => false, loginOidc: jest.fn() },
      },
      { provide: Router, useValue: router },
    ],
  });

  it('navega a /login al pulsar el botón', () => {
    const s = create();
    s.click('.acceso-boton');
    expect(router.navigate).toHaveBeenCalledWith(['/login']);
  });
});

describe('BienvenidaPage (ya autenticado)', () => {
  const router = { navigate: jest.fn() };
  const create = createComponentFactory({
    component: BienvenidaPage,
    providers: [
      { provide: AuthService, useValue: { authMode: 'oidc', autenticado: () => true } },
      { provide: Router, useValue: router },
    ],
  });

  it('redirige a / al cargar', () => {
    create();
    expect(router.navigate).toHaveBeenCalledWith(['/']);
  });
});
