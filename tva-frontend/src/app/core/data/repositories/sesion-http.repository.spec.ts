import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { HttpMethod, createHttpFactory } from '@ngneat/spectator/jest';

import { SesionHttpRepository } from './sesion-http.repository';

describe('SesionHttpRepository', () => {
  const createService = createHttpFactory({
    service: SesionHttpRepository,
    providers: [
      { provide: ENVIRONMENT, useValue: 'test' },
      { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://test/api' } },
    ],
  });

  it('GET sesion', () => {
    const spectator = createService();
    spectator.service.obtener('k').subscribe();
    spectator.expectOne('http://test/api/sesiones/k/', HttpMethod.GET).flush({});
  });

  it('POST accion', () => {
    const spectator = createService();
    let res: { pantallaActual?: string } = {};
    spectator.service.ejecutarAccion('k', 'siguiente', { x: 1 }).subscribe(r => (res = r));
    const req = spectator.expectOne(
      'http://test/api/sesiones/k/acciones/siguiente/',
      HttpMethod.POST
    );
    expect(req.request.body).toEqual({ datos: { x: 1 } });
    req.flush({ pantallaActual: 'FIN', avisos: [], estado: {} });
    expect(res.pantallaActual).toBe('FIN');
  });

  it('PUT estado', () => {
    const spectator = createService();
    spectator.service.guardarEstado('k', { a: 1 }).subscribe();
    const req = spectator.expectOne('http://test/api/sesiones/k/estado/', HttpMethod.PUT);
    expect(req.request.body).toEqual({ estado: { a: 1 } });
    req.flush({});
  });

  it('validar-seccion delega en acciones', () => {
    const spectator = createService();
    spectator.service.validarSeccion('k', 'CAJA', 'seccion1', { d: 1 }).subscribe();
    const req = spectator.expectOne(
      'http://test/api/sesiones/k/acciones/validar-seccion/',
      HttpMethod.POST
    );
    expect(req.request.body).toEqual({
      datos: { caja: 'CAJA', seccion: 'seccion1', datos: { d: 1 } },
    });
    req.flush({});
  });
});
