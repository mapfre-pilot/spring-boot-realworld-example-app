import { Router } from '@angular/router';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { AuthService } from '@tva/core';
import { LoginPage } from './login.page';

describe('LoginPage', () => {
  const auth = { login: jest.fn() };
  const router = { navigate: jest.fn() };
  const create = createComponentFactory({
    component: LoginPage,
    providers: [
      { provide: AuthService, useValue: auth },
      { provide: Router, useValue: router },
    ],
  });

  it('exige token y llama a login + navegación al entrar', () => {
    const s: Spectator<LoginPage> = create();
    const spy = auth.login;
    spy.mockClear();
    router.navigate.mockClear();
    s.component['form'].controls.token.setValue('tok123');
    s.component['entrar']();
    expect(spy).toHaveBeenCalledWith('tok123');
    expect(router.navigate).toHaveBeenCalledWith(['/']);
  });
});
