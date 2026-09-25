import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { AuthService } from './auth.service';
import { roleGuard } from './guards';

function tokenCon(roles: string[]): string {
  const b64 = (o: object) => btoa(JSON.stringify(o)).replace(/=/g, '');
  return `${b64({ alg: 'HS256' })}.${b64({ sub: 'u', roles, exp: 9999999999 })}.sig`;
}

describe('roleGuard', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideRouter([]),
        { provide: ENVIRONMENT, useValue: 'test' },
        {
          provide: ENVIRONMENT_CONFIG,
          useValue: { apiBaseUrl: 'x', auth: { tokenStorageKey: 'spec_tva' } },
        },
      ],
    });
  });

  it('permite con rol TVA_ADMIN_PORTAL', () => {
    const auth = TestBed.inject(AuthService);
    auth.login(tokenCon(['TVA_USUARIO', 'TVA_ADMIN_PORTAL']));
    const res = TestBed.runInInjectionContext(roleGuard('TVA_ADMIN_PORTAL'));
    expect(res).toBe(true);
  });

  it('redirige sin el rol', () => {
    const auth = TestBed.inject(AuthService);
    auth.login(tokenCon(['TVA_USUARIO']));
    const res = TestBed.runInInjectionContext(roleGuard('TVA_ADMIN_PORTAL'));
    expect(res).not.toBe(true);
  });
});
