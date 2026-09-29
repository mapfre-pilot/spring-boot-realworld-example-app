import { TestBed } from '@angular/core/testing';
import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { EnvironmentService } from './environment.service';

describe('EnvironmentService', () => {
  it('expone el entorno y la configuración inyectados', () => {
    TestBed.configureTestingModule({
      providers: [
        { provide: ENVIRONMENT, useValue: 'dev' },
        {
          provide: ENVIRONMENT_CONFIG,
          useValue: { apiBaseUrl: 'http://x', auth: { mode: 'local' } },
        },
      ],
    });
    const env = TestBed.inject(EnvironmentService);
    expect(env.env).toBe('dev');
    expect(env.config.apiBaseUrl).toBe('http://x');
    expect(env.config.auth?.mode).toBe('local');
  });
});
