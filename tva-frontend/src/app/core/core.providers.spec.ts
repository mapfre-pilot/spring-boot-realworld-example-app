import { TestBed } from '@angular/core/testing';
import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { provideTvaCore } from './core.providers';
import { ADMIN_REPOSITORY, SESION_REPOSITORY } from './ports';

describe('provideTvaCore', () => {
  it('registra los repositorios HTTP en el contenedor', () => {
    TestBed.configureTestingModule({
      providers: [
        provideTvaCore(),
        { provide: ENVIRONMENT, useValue: 'dev' },
        { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://localhost:1' } },
      ],
    });
    expect(TestBed.inject(SESION_REPOSITORY)).toBeTruthy();
    expect(TestBed.inject(ADMIN_REPOSITORY)).toBeTruthy();
  });
});
