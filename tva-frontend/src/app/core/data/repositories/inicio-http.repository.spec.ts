import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { HttpMethod } from '@ngneat/spectator/jest';
import { createHttpFactory } from '@ngneat/spectator/jest';

import { InicioHttpRepository } from './inicio-http.repository';

describe('InicioHttpRepository', () => {
  const createService = createHttpFactory({
    service: InicioHttpRepository,
    providers: [
      { provide: ENVIRONMENT, useValue: 'test' },
      { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://test/api' } },
    ],
  });

  it('GET salud', () => {
    const spectator = createService();
    spectator.service.salud().subscribe(r => expect(r.status).toBe('ok'));
    const req = spectator.expectOne('http://test/api/salud/', HttpMethod.GET);
    req.flush({ status: 'ok', version: '0.0.1' });
  });

  it('POST inicio/ahorro', () => {
    const spectator = createService();
    let res: unknown;
    spectator.service.iniciarAhorro({ indFunctionMode: 'VA' } as never).subscribe(r => (res = r));
    const req = spectator.expectOne('http://test/api/inicio/ahorro/', HttpMethod.POST);
    req.flush({ claveSesion: 'k', pantallaActual: 'SEGUROS_AHORRO' });
    expect(res).toEqual({ claveSesion: 'k', pantallaActual: 'SEGUROS_AHORRO' });
  });

  it('POST inicio/rentas', () => {
    const spectator = createService();
    spectator.service.iniciarRentas({ indFunctionMode: 'R2C' } as never).subscribe();
    spectator.expectOne('http://test/api/inicio/rentas/', HttpMethod.POST).flush({});
  });
});
