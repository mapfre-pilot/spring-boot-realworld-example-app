import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { HttpMethod, createHttpFactory } from '@ngneat/spectator/jest';

import { AdminHttpRepository } from './admin-http.repository';

describe('AdminHttpRepository', () => {
  const createService = createHttpFactory({
    service: AdminHttpRepository,
    providers: [
      { provide: ENVIRONMENT, useValue: 'test' },
      { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://test/api' } },
    ],
  });

  it('GET parametros', () => {
    const spectator = createService();
    spectator.service.parametros().subscribe();
    spectator.expectOne('http://test/api/admin/parametros/', HttpMethod.GET).flush([]);
  });

  it('POST apertura-cierre y limpiar caches', () => {
    const spectator = createService();
    spectator.service.aperturaCierre().subscribe();
    spectator.expectOne('http://test/api/admin/apertura-cierre/', HttpMethod.POST).flush({});
    spectator.service.limpiarCaches().subscribe();
    spectator.expectOne('http://test/api/admin/caches/limpiar/', HttpMethod.POST).flush({});
  });

  it('GET trazas con clave opcional', () => {
    const spectator = createService();
    spectator.service.trazas('k').subscribe();
    const req = spectator.controller.expectOne(r => r.url === 'http://test/api/admin/trazas/');
    expect(req.request.params.get('clave')).toBe('k');
    req.flush([]);
  });
});
