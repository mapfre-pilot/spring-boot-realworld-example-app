import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { HttpMethod, createHttpFactory } from '@ngneat/spectator/jest';

import { CatalogoHttpRepository } from './catalogo-http.repository';

describe('CatalogoHttpRepository', () => {
  const createService = createHttpFactory({
    service: CatalogoHttpRepository,
    providers: [
      { provide: ENVIRONMENT, useValue: 'test' },
      { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://test/api' } },
    ],
  });

  it('GET catalogo', () => {
    const spectator = createService();
    spectator.service.catalogo('sexos').subscribe();
    spectator.expectOne('http://test/api/catalogos/sexos/', HttpMethod.GET).flush({ valores: [] });
  });

  it('GET clientes con parámetro documento', () => {
    const spectator = createService();
    spectator.service.clientes('00000000T').subscribe();
    const req = spectator.controller.expectOne(r => r.url === 'http://test/api/clientes/');
    expect(req.request.params.get('documento')).toBe('00000000T');
    req.flush({});
  });

  it('GET productos', () => {
    const spectator = createService();
    spectator.service.productos({ companyId: '90' }).subscribe();
    const req = spectator.controller.expectOne(r => r.url === 'http://test/api/productos/');
    expect(req.request.params.get('companyId')).toBe('90');
    req.flush({ products: [] });
  });
});
